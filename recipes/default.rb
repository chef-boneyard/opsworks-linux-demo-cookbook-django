include_recipe 'build-essential'

app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"

package node['django-demo']['mysql_package_name']

package 'git' do
  # workaround for:
  # WARNING: The following packages cannot be authenticated!
  # liberror-perl
  # STDERR: E: There are problems and -y was used without --force-yes
  options '--force-yes' if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
end

application app_path do
  git app_path do
    repository app['app_source']['url']
    action :sync
  end

  python '2'
  virtualenv
  pip_requirements

  file ::File.join(app_path, 'dpaste', 'settings', 'deploy.py') do
    content "from dpaste.settings.base import *\nfrom dpaste.settings.local_settings import *\n"
  end

  django do
    allowed_hosts ['localhost', node['cloud']['public_ipv4'], node['fqdn']]
    settings_module 'dpaste.settings.deploy'
    database 'sqlite:///dpaste.db'
    syncdb true
    migrate true
  end

  gunicorn
end
