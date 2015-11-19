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

An *AWS OpsWorks app* represents code that you want to run on an application server. Code is stored in source control in git, or as a bundle on AWS S3 or as an http archive. 

An *AWS OpsWorks* instance represents a computing resource, such as an Amazon EC2 instance. 

An *AWS OpsWorks layer* is a blueprint that describes a set of one or more instances. The layer defines the packages that are installed and configurations.  Instances can belong to multiple layers, as long as the layers don't have overlapping configurations.

An *AWS OpsWorks stack* is the top-level AWS OpsWorks entity. Each stack will contain one or more layers which each contain instances. As a whole, the stack represents a set of instances that you want to manage collectively. An example of a web application stack might look something like:

* A set of application server instances.
* A load balancer instance which takes incoming traffic and distributes it across the application servers.
* A database instance, which serves as a back-end data store for the application servers.

A common practice is to have multiple stacks that represent different environments. A typical set of stacks might consist of a development, staging, and production stacks. 

An *AWS OpsWorks lifecycle event* is one of a set of 5 events that can occur with an *AWS OpsWorks layer*: Setup, Configure, Deploy, Undeploy, and Shutdown.At each layer there will be a set of recipes associated and run when the [lifecycle event](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-events.html) is triggered. 


### Django Terminology

Within Django an *app* is a Web application that does something, for example a poll app. Within Django a *project* is a collection of apps and configurations. An *app* can be in multiple projects.

Django follows the MVC(Model View Controller) architectural pattern. The model will handle all the data and business logic. The view will present data to the user in the supported format and layout. The controller will receive the requests (HTTP GET or POST for example), coordinate, and call the appropriate resources to carry them out. 

When creating a web application, we generally create a set of controllers, models, and views. The reason that it uses this pattern is to provide some separation between the presentation (what the user sees) and the application logic. 

In Django, [the view pattern is implemented through an abstraction called a  template and the controller pattern is implemented through an abstraction called a view](https://docs.djangoproject.com/en/1.8/faq/general/#django-appears-to-be-a-mvc-framework-but-you-call-the-controller-the-view-and-the-view-the-template-how-come-you-don-t-use-the-standard-names). 

### Django Installation Requirements

There are core applications required to install [Django](https://docs.djangoproject.com): Python, pip, and virtualenv. You have a number of choices that may change how you want to deploy within your environment, for example what version of Python you are using as a standard within your organization. Before you run something in production, you should always understand the implications of what you are doing, and why. 

### Django Deployment Requirements 

In order for Django to be useful, you also need a few other applications: WSGI-compatible web server, and a database application.

The Web Server Gateway Interface (WSGI) is a specification for a simple and universal interface between a web server and web application for Python, in other words the communication strategy. The goal is that any application written to the spec will run on any server that also complies to the spec.

A WSGI-compatible web server will receive client requests and pass them to the underlying WSGI-compatible web application. It will also receive responses from the web application and return them to the client. 

In this how-to, we will use gunicorn, a lightweight Python WSGI HTTP server. 

### Django File Structure

The root directory naming is useful to you but doesn't matter to Django. You can name it whatever you want, and is just a container for the Django project.

Within the root directory, there are a number of critical files.

The *manage.py* file is a command-line utility to manage the specific Django project. 

The app directory within your root directory is the actual Python package for your project. The name of this project directory is the name of the Python package you will need to use to import anything inside of it. For example project *mysite*, would have *mysite.urls*.

Within the project directory, *\_\_init\_\_.py* exists as an empty file that marks it as a Python package. 

Within the project directory, *settings.py* has specific configuration information about this Django project. 

Within the project directory, *urls.py* has the URL declarations for this Django project, essentially this is the table of contents. 

Within the project directory, *wsgi.py* has the configuration information for the WSGI-compatible web servers that will serve the Django project.

## Introducing the Django App Server layer

The Django App Server layer is an AWS OpsWorks layer that will provide a blueprint for instances that function as Django application servers. It is based on python, pip, and virtualenv. 
 
### Using the Django App Server layer

*Note*: Make sure that you do not use the app name of *test* or *django* as these names will cause conflicts with Python or Django.

*Note*: When you choose a location for your Django source, don't drop it in your web server's document root. Django is separate from your web server and you don't want to expose the underlying code.

## Walkthrough

Now that we've set the context of what we are doing, let's take a look at this sample cookbook and walkthrough the process of using it.

### Prerequisites and Assumptions

For the purposes of this walkthrough, we assume that you have the following setup on your working environment:

* git (or some mechanism to access and download the sample repo)
* Chef Development Kit (chefdk)
* Vagrant 

We also assume that in your AWS environment that you have:

* Signed up for an AWS account
* Availability of an IAM User
* Service Access Permissions with your IAM user
* [AWS Command Line Tool(AWS CLI)](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed

If you do not have the AWS environment minimal requirements, check out the process here to get this setup. 

You don't have to use the AWS CLI, just take the process and apply it to the GUI in the AWS console.  

### 

*Note*: The AWS OpsWorks CLI endpoint is only available in region *us-east-1*. This region specification is separate from the stack's region configuration. 


Amazon Resource Names(ARNs) uniquely identify resources on AWS. To work with AWS OpsWorks, we need to obtain the *ServiceRoleArn* ARN. 

```
SERVICE_ROLE_ARN=$(aws opsworks describe-stacks --query 'Stacks[*].ServiceRoleArn' --output text |awk '{ print $1 }')
```

In this command, we are using the AWS OpsWorks CLI *describe-stacks* command to pull information about the stacks, pulling out just the ServiceRoleArn in order to use it later. 

```
DEFAULT_INSTANCE_PROFILEs_ARN=$(aws opsworks describe-stacks --query 'Stacks[*].DefaultInstanceProfileArn' --output text |awk '{ print $1 }')
```

In this command, we are using the AWS OpsWorks CLI *describe-stacks* command to pull information about the stacks, pulling out just  DefaultInstanceProfileArn.

STACK\_ID=$(aws opsworks --region us-east-1 create-stack --name chef-12 --service-role-arn $SERVICE_ROLE_ARN --default-instance-profile-arn $DEFAULT\_

INSTANCE\_PROFILE_ARN --configuration-manager Name=Chef,Version=12 --stack-region us-west-2 --output text)
LAYER_ID=$(aws opsworks --region us-east-1 create-layer --stack-id $STACK_ID --type custom --name kustom --shortname kustom --output text)
INSTANCE_ID=$(aws opsworks --region us-east-1 create-instance --stack-id $STACK\_ID --layer-id $LAYER_ID --instance-type c3.large --output text)
aws opsworks --region us-east-1 start-instance --instance-id $INSTANCE_ID

ssh ec2-user@IPADDRESS -i SSH\_KEY\_PAIR.pem 


## Further Resources

* [AWS CLI](https://aws.amazon.com/cli/)
* [AWS OpsWorks Lifecycle Events](http://docs.aws.amazon.com/opsworks/latest/userguide/workingcookbook-events.html)
* [Green Unicorn](http://gunicorn.org/)