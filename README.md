# opsworks-linux-demo-cookbook-django Cookbook

This is a reference cookbook to show managing a Django python app on the OpsWorks platform with Chef.

For additional context, you can read the [background](docs/django_blog_post.md).

## Requirements

* Signed up for an AWS account
* IAM User credentials
* Service Access Permissions enabled on your IAM user
* [AWS Command Line Tool (AWS CLI)](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed on your workstation.
* `bash` or equivalent shell

### Platforms

* Tested and verified on Amazon Linux 2015.09

### Chef
- Chef 12+


### Cookbooks
- application_python
- build-essential
- poise-python


## Usage

* run `berks package`
* upload `cookbooks-*.tar.gz` to the appropriate artifactory repository.
* create stack using custom chef cookbooks
* create custom layer
* add `opsworks-linux-demo-cookbook-django` as recipe in `setup`
* create app, using e.g. https://github.com/bartTC/dpaste.git as a source
* start instance
* goto http://public IP of your instance/


## License & Authors
**Author:** Cookbook Engineering Team ([cookbooks@chef.io](mailto:cookbooks@chef.io))

**Copyright:** 2015, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
