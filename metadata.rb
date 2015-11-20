name 'opsworks-linux-demo-cookbook-django'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Reference cookbook to show managing Django python app on OpsWorks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'application_python'
depends 'build-essential'
depends 'poise-python'

source_url 'https://github.com/chef-cookbooks/opsworks-linux-demo-cookbook-django' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/opsworks-linux-demo-cookbook-django/issues' if respond_to?(:issues_url)
