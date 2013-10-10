#
# Cookbook Name:: mysql-official-rpm
# Recipe:: server
#

include_recipe 'mysql-official-rpm::client'

# MySQL
MYSQL_ROOT_PASSWORD = 'devrootpass'
MYSQL_VERSION = '5.6.14-1'

# install from RPM
filename = "MySQL-server-#{MYSQL_VERSION}.el6.x86_64.rpm"

cookbook_file "/tmp/#{filename}" do
  source "#{filename}"
end

rpm_package "MySQL-server" do
  action :install
  provider Chef::Provider::Package::Rpm
  source "/tmp/#{filename}"
end

service "mysql" do
  action [:enable, :start]
end

# secure install and create development database/user
script "Secure_Install" do
  interpreter 'bash'
  user "root"
  not_if "mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e 'show databases'"
  code <<-EOL
    export Initial_PW=`head -n 1 /root/.mysql_secret |awk '{print $(NF - 0)}'`
    mysql -u root -p${Initial_PW} --connect-expired-password -e "SET PASSWORD FOR root@localhost=PASSWORD('#{MYSQL_ROOT_PASSWORD}');"
    mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e "SET PASSWORD FOR root@'127.0.0.1'=PASSWORD('#{MYSQL_ROOT_PASSWORD}');"
    mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1');"
    mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e "DROP DATABASE test;"
    mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -p#{MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
  EOL
end
