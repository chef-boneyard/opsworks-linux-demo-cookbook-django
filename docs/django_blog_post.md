# Using Chef Community Cookbooks with AWS OpsWorks 

In this post, I will walk through the process of using community cookbooks with AWS OpsWorks. We'll create a simple web application using Django. This isn't an in-depth guide; while I'll point out some key components to think about with a working example, prior to deploying to your environment you should ensure that you think through your specific concerns. I look forward to hearing your feedback and any modifications that you test out.  

## Background

Web application frameworks provide a set of components that are common across applications allowing an individual to speed up development and deployment of a web application. Functionality like user authentication and authorization, forms, file management, are some examples of these common components. These frameworks exist to speed up delivery so that you don't have to reinvent the wheel each time you want to create a site. 

Django is a free and open source web application framework written in Python. 

## Basics

Before we get too much further, we'll talk about the basic vocabulary involved with managing applications with Chef and OpsWorks.

### Chef Basics

Within Chef, we have the concepts of _resources_, _recipes_, and _cookbooks_. 

Resources are the basic building blocks of our infrastructure. We can use resources as provided by core chef, pull resources in from community cookbooks or we can extend and customize our own resources. 

Recipes are the algorithm to describe a specific piece of an application that we want to have running on a system. It's the ordered set of resources and potentially additional ruby code for logic and flow control. Just as with a recipe for baking chocolate chip cookies or oatmeal cookies, the recipe will be specific to what we want to create. 

Cookbooks are where we collect all of our recipes, and other supporting files. We can create our own or pull from the community cookbook repository, Supermarket. 

One great thing about chef community cookbooks is that you can reuse what makes sense for you, and create more specific cookbooks and recipes within your environment.

### OpsWorks Basics

As we needed to have a common understanding of terminology before working with Chef abstractions, we need to understand the common understanding of terminology with Opsworks abstractions. There are 5 key OpsWorks abstractions: _apps_, _instances_, _layers_, _lifecycle events_, and _stacks_.

An **AWS OpsWorks app** represents code that you want to run on an application server. Code is stored in source control in git, or as a bundle on AWS S3 or as an http archive. 

An **AWS OpsWorks instance** represents a computing resource, such as an Amazon EC2 instance. 

An **AWS OpsWorks layer** is a blueprint that describes a set of one or more instances. The layer defines the packages that are installed and configurations.  Instances can belong to multiple layers, as long as the layers don't have overlapping configurations.

An **AWS OpsWorks stack** is the top-level AWS OpsWorks entity. Each stack will contain one or more layers which each contain instances. As a whole, the stack represents a set of instances that you want to manage collectively. An example of a web application stack might look something like:

* A set of application server instances.
* A load balancer instance which takes incoming traffic and distributes it across the application servers.
* A database instance, which serves as a back-end data store for the application servers.

A common practice is to have multiple stacks that represent different environments. A typical set of stacks might consist of a development, staging, and production stacks. 

An *AWS OpsWorks lifecycle event* is one of a set of 5 events that can occur with an *AWS OpsWorks layer*: Setup, Configure, Deploy, Undeploy, and Shutdown.At each layer there will be a set of recipes associated and run when the [lifecycle event](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-events.html) is triggered. 

### Django Terminology

Within Django an **app** is a Web application that does something, for example a poll app. Within Django a **project** is a collection of apps and configurations. An **app** can be in multiple projects.

Django follows the MVC(Model View Controller) architectural pattern. In the MVC architectural pattern, the model handls all the data and business logic, the view presents data to the user in the supported format and layout, and the controller receives the requests (HTTP GET or POST for example), coordinates, and calls the appropriate resources to carry them out. 

When creating a web application, we generally create a set of controllers, models, and views. The reason that it uses this pattern is to provide some separation between the presentation (what the user sees) and the application logic. 

In Django, the view pattern is implemented through an abstraction called a  **template** and the controller pattern is implemented through an abstraction called a **view**.[1][1]. 

### Django Installation Requirements

There are core applications required to install [Django](https://docs.djangoproject.com): Python, a package management system like pip, and optionally **virtualenv**, a way to isolate your python environments. You have a number of choices that may change how you want to deploy within your environment, for example what version of Python you are using as a standard within your organization. Before you run something in production, you should always understand the implications of what you are doing, and why. 

Understanding the requirements of our application help us decide on how we will approach automating the installation. It also helps us in understanding whether a community cookbook serves our needs, what customizations we might need, and the overall effort of those customizations.



### Django Deployment Requirements 

In order for Django to be useful, you also need a few additional applications: WSGI-compatible web server, and a database application.

The **Web Server Gateway Interface (WSGI)** is a specification for a simple and universal interface between a web server and web application for Python, in other words the communication strategy. The goal is that any application written to the spec will run on any server that also complies to the spec.

A WSGI-compatible web server will receive client requests and pass them to the underlying WSGI-compatible web application. It will also receive responses from the web application and return them to the client. 

**Note**: In this how-to post, we are deploying a Django app, ``dpaste`` from code straight off of github ``https://github.com/bartTC/dpaste``. In general you shouldn't do this, as you should validate the software that you are installing does what you want it to do. For the purpose of understanding the concepts in this post, it works. 

dpaste is a Django based pastebin. Based off [installation instructions](http://dpaste.readthedocs.org/en/latest/installation.html), we know that we need to do the following things to get dpaste running:

* Get the application code locally.
* Create a virtualenv.
* Install the required python packages into the environment.
* Sync the models to the database.
* Propagate models to the database schema.
* Start up a web server.

In this how-to, we will use **gunicorn**, a lightweight Python WSGI HTTP server. 

### Django File Structure

The root directory naming is useful to you but doesn't matter to Django. You can name it whatever you want, and is just a container for the Django project.

Within the root directory, there are a number of critical files.

The `manage.py` file is a command-line utility to manage the specific Django project. 

The app directory within your root directory is the actual Python package for your project. The name of this project directory is the name of the Python package you will need to use to import anything inside of it. For example project **mysite**, would have `mysite.urls`.

Within the project directory, `__init__.py` exists as an empty file that marks it as a Python package. 

Within the project directory, `settings.py` has specific configuration information about this Django project. 

Within the project directory, `urls.py` has the URL declarations for this Django project, essentially this is the table of contents. 

Within the project directory, `wsgi.py` has the configuration information for the WSGI-compatible web servers that will serve the Django project.

## Introducing the Chef Community Supermarket

The hosted [Chef Supermarket](http://supermarket.chef.io) is the location to find community shared cookbooks. Some of these cookbooks are maintained by my team, the Community Engineering team, others are maintained by individuals in the community.

In our example cookbook, we will be using the [application_python](https://supermarket.chef.io/cookbooks/application_python) cookbook to manage our Django app. We could custom create a cookbook, but for the purpose of this how-to this cookbook is sufficient.

The Supermarket interface gives us quite a bit of information about this cookbook. It shows the README which has information about quickly getting started, requirements, and dependencies. We can go directly to the source code, or [download the cookbook](https://supermarket.chef.io/cookbooks/application_python/download) direct from the Supermarket.

A key requirement to note is that **Chef 12** or later are required. Make sure that if you modify the instructions in this how-to that at minimum you use Chef 12. 

## Introducing the Django App Server layer

The Django App Server layer is an AWS OpsWorks layer that will provide a blueprint for instances that function as Django application servers. It is based on python, pip, and virtualenv. 
 
### Using the Django App Server layer

**Note**: Make sure that you do not use the app name of **test** or **django** as these names will cause conflicts with Python or Django.

**Note**: When you choose a location for your Django source, don't drop it in your web server's document root. Django is separate from your web server and you don't want to expose the underlying code.

## Walkthrough

Now that we've set the context of what we are doing, let's take a look at this sample cookbook and walkthrough the process of using it.

### Prerequisites and Assumptions

For the purposes of this walkthrough, we assume that you have the following setup on your working environment:

* [git (or some mechanism to access and download the sample repo)](https://git-scm.com/downloads)
* [Chef Development Kit (chefdk)](https://downloads.chef.io/chef-dk/)

We also assume that in your AWS environment that you have:

* Signed up for an AWS account
* IAM User credentials
* Service Access Permissions enabled on your IAM user
* [AWS Command Line Tool(AWS CLI)](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed on your workstation.

If you do not have the AWS environment minimal requirements, check out the process here to get this setup. 

If you don't have the AWS CLI or the ability to install it, just take the process and apply it to the GUI in the AWS console.  

If you don't already have an AWS configuration, go ahead and create one to simplify your AWS CLI commands. 

Add the following to ``~/.aws/config``, making sure to paste in your ``aws_access_key_id`` and ``aws_secret_access_key`` values. Don't leave these blank! :

```

[default]
region = us-east-1
aws_access_key_id = 
aws_secret_access_key = 

```

### Create your First Stack

**Note**: The AWS OpsWorks CLI endpoint, ``opsworks.us-east-1.amazonaws.com``,  is only available in region *us-east-1*. This region specification is separate from the stack's region configuration. 

**Note**: The AWS OpsWorks CLI configuration variable for the Chef Version is ``ConfigurationManager``. Make sure that you are specifying at minimum Chef Version 12. 

Amazon Resource Names(ARNs) uniquely identify resources on AWS. To work with AWS OpsWorks, we need to obtain the **ServiceRoleArn** ARN. To do this, we will first need to create a stack, and then get the **ServiceRoleArn**.

Remember, that the **AWS OpsWorks stack** is the top-level AWS OpsWorks entity that will contain our layers.

   1. Using your IAM user, sign in to the AWS OpsWorks console at https://console.aws.amazon.com/opsworks.
   2. Do one of the following:
      * If the Welcome to AWS OpsWorks page displays, choose Add your first stack or Add your first AWS OpsWorks stack. The Add stack page displays.
      * If the OpsWorks Dashboard page displays, choose Add stack. The Add stack page displays.
      * If the Add stack page displays, don't do anything else yet.
   3. Select the Chef 12 stack.
   4. Fill in the form as follows:
      * Stack name DjangoTestStack
      * Region US West (Oregon)
      * Default operating system Linux Red Hat Enterprise 7
   5. Click on custom Chef cookbooks Yes.
   6. Fill in the custom Chef cookbooks form with the following information:
      * Repository type Git
      * Repository URL https://s3.amazonaws.com/chef-django-opswork-test/opsworks-linux-demo-cookbook-django.tar.gz
   7. Click on Advanced to get further options.
   8. Fill in the Advanced form as follows.
      * OpsWorks Agent version "Use latest version"
   9. Click on Add Stack.

The following commands assume an AWS configuration that has been set with the region information as **us-east-1**. If you can't set this in your configuration you will need to add a flag ``--region us-east-1`` to each of these commands. 

Verify that you can see your newly created stack by using the AWS CLI.

```
$ aws opsworks describe-stacks
```

Set up an environmental variable of ``SERVICE_ROLE_ARN``:

```
SERVICE_ROLE_ARN=$(aws opsworks describe-stacks --query 'Stacks[*].ServiceRoleArn' --output text |awk '{ print $1 }')
```

In this command, we are using the AWS OpsWorks CLI *describe-stacks* command to pull information about the stacks, pulling out just the ServiceRoleArn in order to use it later. 

Set up an environmental variable of ``DEFAULT_INSTANCE_PROFILEs_ARN``:

```
DEFAULT_INSTANCE_PROFILEs_ARN=$(aws opsworks describe-stacks --query 'Stacks[*].DefaultInstanceProfileArn' --output text |awk '{ print $1 }')
```

In this command, we are using the AWS OpsWorks CLI *describe-stacks* command to pull information about the stacks, pulling out just  DefaultInstanceProfileArn.

Obtain the StackId of the stack we just created. If you are already using AWS OpsWorks and have existing stacks, you'll need to determine this and set STACK_ID appropriately.

```
STACK_ID=$(aws opsworks describe-stacks --query 'Stacks[*].StackId' --output text)
```

We have created an **AWS OpsWorks stack** called **DjangoTestStack** that will contain the layers that we will create next. As a whole, this stack will represent the set of instances that we want to manage collectively.

### Create your First Layer

Next we will create our first layer. Remember that an **AWS OpsWorks layer** is a blueprint that describes a set of one or more instances. The shortname is required to only contain lower case a-z, 0-9, and - or _ characters.

```
LAYER_ID=$(aws opsworks create-layer --stack-id $STACK_ID --type custom --name DjangoDemoLayer --shortname djangodemolayer --output text)
```

Examine the layer you just created.

```
aws opsworks describe-layers --layer-ids $LAYER_ID
```


### Add an App

    1. In the service navigation pane, choose Apps, as displayed in the following screenshot:
    2. The Apps page displays. Choose Add an app. The Add App page displays.
    3. For Settings, for Name, type dpaste. 
    4. For Application Source, for Repository URL, type
    https://github.com/bartTC/dpaste.git



### Add an Instance to your Layer

Add a ```c3.large``` instance to our Layer.

```
    INSTANCE_ID=$(aws opsworks  create-instance --stack-id $STACK_ID --layer-id $LAYER_ID --instance-type c3.large --output text)

```

Start our instance.

```
    aws opsworks start-instance --instance-id $INSTANCE_ID
```

Examine our instance.

```
    aws opsworks describe-instances --instance-ids $INSTANCE_ID
```

It will take a few minutes for the instance to finish spinning up, so be patient.  Status will progress from **stopped** to **requested**, to **pending**, to **booting**, to **running_setup**, and then finally to **online**. 

After **Status** changes to **online**, **setting up** changes from **1** to **0**, online changes from **0** to **1**.

Obtain the IP Address of the instance that was just created.

```

IPADDRESS=$(aws opsworks describe-instances --instance-ids $INSTANCE_ID --query 'Instances[*].PublicIp' --output text)

```

Now that you have created a functioning stack, layer, and instances, you can create additional stacks using the AWS CLI. You just need the ``ServiceRoleArn`` and the ``DefaultInstanceProfileArn`` which we obtained earlier in this how-to post.

The command looks like this:

```
STACK_ID=$(aws opsworks create-stack --name STACK_NAME --service-role-arn $SERVICE_ROLE_ARN --default-instance-profile-arn $DEFAULT
```

### Examining our recipe

Within our default recipe, we are using the ``package`` resource to install ``git`` on our node.

```
package 'git' do
  options '--force-yes' if node['platform'] == 'ubuntu' && node['platform_version'] == '14.04'
end
```

Next, we are using the ``application`` resource. 

```
application app_path do
 ...
end
```

``app_path`` is a ruby variable that we have defined at the top of our recipe based off of the ``AWS OpsWork App`` name that we created earlier.

```
app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"
```

Within the ``application`` resource we are defining a ``git`` parameter.

```
git app_path do
  repository app['app_source']['url']
  action :sync
end
```
This ``git`` parameter is based off of the value that we set for the ``AWS OpsWork App`` Application Source Repository URL value earlier, i.e. ``https://github.com/bartTC/dpaste.git``.

Next, within the ``application`` resource, we are defining additional parameters. If you were writing a wrapper around the ``application_python`` cookbook, this is one place you would customize based on your requirements. For this guide, we are using the latest python 2 and configuring a virtualenv for our environment based off of the application name, ``dpaste``.

```  
  python '2'
  virtualenv
```

Next, within the ``application`` resource, we have the parameter ``pip_requirements``. This parameter makes sure that ``pip install -r requirements.txt`` is run. This is a python standard to install python packages within the virtualenv based off of a ``requirements.txt`` file.[2][] 

For our application, this requirements.txt file is coming from our source code ``https://github.com/bartTC/dpaste/blob/master/requirements.txt``. 

```
  pip_requirements
```

Next, we add additional configuration information to the ``dpaste/settings/deploy.py`` file. 

TODO -- need to fix the path here, as it's incorrect within the scope of opsworks. probably should just say the app name is dpaste to eliminate the troubles here. 

```
  file ::File.join(path, 'dpaste', 'settings', 'deploy.py') do
    content "from dpaste.settings.base import *\nfrom dpaste.settings.local_settings import *\n"
  end

```

Next within the ``application`` resource, we specify the ``django`` parameter. This is a very detailed parameter with a lot going on. Within this block we:

* configure Django to be installed, 
* allow connections to Django from localhost only, 
* add the Dpaste application to the 
* configure the Django Object Relational Mapping(ORM) to use a local SQLite database,
* sync our models to our database,
* propagate changes to our models to our database schema.

```
  django do
    allowed_hosts ['localhost', node['fqdn']]
    settings_module 'dpaste.settings.deploy'
    database 'sqlite:///dpaste.db'
    syncdb true
    migrate true
  end

```

Finally, within our ``application`` resource, we set up the required WSGI-compatible web server, **gunicorn**, a lightweight Python WSGI HTTP server. 

```
  gunicorn

```

Without any additional configuration, we are accepting the default, which will have gunicorn running on port 80. 


### Cleanup

stop-instance
stop-stack
delete-app
delete-instance
delete-layer
delete-stack

### Summary








## Further Resources


* [Chef Supermarket](http://supermarket.chef.io)
* [Vagrant](https://www.vagrantup.com/) 
* [AWS CLI](https://aws.amazon.com/cli/)
* [AWS OpsWorks Lifecycle Events](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-events.html)
* [Green Unicorn](http://gunicorn.org/)

[1]: https://docs.djangoproject.com/en/1.8/faq/general/#django-appears-to-be-a-mvc-framework-but-you-call-the-controller-the-view-and-the-view-the-template-how-come-you-don-t-use-the-standard-names
[2]: http://pip.readthedocs.org/en/stable/reference/pip_install/#overview