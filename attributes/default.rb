case node['platform_family']
when 'rhel'
  if node['platform_version'].to_i >= 7 && node['platform'] != 'amazon'
    default['django-demo']['mysql_package_name'] = 'mariadb-devel'
  else
    default['django-demo']['mysql_package_name'] = 'mysql-devel'
  end
when 'debian'
  default['django-demo']['mysql_package_name'] = 'libmysqlclient-dev'
end
