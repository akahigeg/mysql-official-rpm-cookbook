#
# Cookbook Name:: mysql-official-rpm
# Recipe:: client
#

# MySQL
MYSQL_VERSION = '5.6.14-1'

# remove default installed packages
['mysql', 'mysql-devel', 'mysql-libs'].each do |pkg|
  package pkg do
    action :remove
  end
end

# install from RPM
mysql_packages = ['client', 'devel', 'shared', 'shared-compat']
mysql_packages.each do |pkg|
  filename = "MySQL-#{pkg}-#{MYSQL_VERSION}.el6.x86_64.rpm"
  cookbook_file "/tmp/#{filename}" do
    source "#{filename}"
  end

  rpm_package "MySQL-#{pkg}" do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/tmp/#{filename}"
  end
end
