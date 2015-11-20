
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

### Django Basics

Django is a free and open source web application framework written in Python.

Web application frameworks provide a set of components that are common across applications allowing an individual to speed up development and deployment of a web application. Functionality like user authentication and authorization, forms, file management, are some examples of these common components. These frameworks exist to speed up delivery so that you don't have to reinvent the wheel each time you want to create a site.

Within Django an **app** is a Web application that does something, for example a poll app. Within Django a **project** is a collection of apps and configurations. An **app** can be in multiple projects.

Django follows the MVC(Model View Controller) architectural pattern. In the MVC architectural pattern, the model handls all the data and business logic, the view presents data to the user in the supported format and layout, and the controller receives the requests (HTTP GET or POST for example), coordinates, and calls the appropriate resources to carry them out. 

When creating a web application, we generally create a set of controllers, models, and views. The reason that it uses this pattern is to provide some separation between the presentation (what the user sees) and the application logic. 

In Django, the view pattern is implemented through an abstraction called a  **template** and the controller pattern is implemented through an abstraction called a **view**.[1][1]. 