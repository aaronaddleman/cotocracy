# What

Super simple configuration management system

# Why

To see if it can be done in a different way

# How

## Overview

The components of this program are as follows:

* Organization (has many projects)
* Projects (has many jobs, environments)
* Jobs (has many tasks)
* Tasks (holds the command for execution)
* Environments (holds variables for substitution in tasks)
* Runner (executes the tasks using the environment variables)

## Project

To make a new project, use the following example:

```
phpApp = Project.new(:name => "NAME OF PROJECT")
```

## Environment

To make an environment, use the following example:

```
dev = Environment.new(:name => "development", :type => :development)
```

Below are some examples on how to add some variables:

```
dev.add_variable(:keyname => "helloworld", :role => "content", :value => "hello world this is the php app")
dev.add_variable(:keyname => "appdir", :role => "path", :value => "/opt/helloworld")
dev.add_variable(:keyname => "frontend1", :role => "instance", :value =>  {:fqdn => "frontend-001.internal.dev", :ipaddress => "54.158.155.138"})
```

## Tasks

Create tasks in an array to be used for order of execution. Below is an example:

```
installation_tasks = [
  Task.new(:name => "install_lamp_apt_update", :command => "apt-get update"),
  Task.new(:name => "install_lamp_apt_update", :command => "apt-get install lamp-server"),
  Task.new(:name => "install_lamp", :command => "ls %%appdir-path%%"),
  Task.new(:name => "install_lamp", :command => "dig google.com")
]
```

## Jobs

After the tasks have been made, create and add them to a new job:

```
# new job
install_deps = Job.new(:name => 'install deps', 
                       :tasks => installation_tasks)

# adding job to the project
phpApp.add_job(install_deps)

```

## Runners

Now the last part, creating and executing the tasks stored in the jobs, with a selected environment:

```
# creating the runners and execute
runner_prod = Runner.new(:environment => prod, :project => phpApp).execute
runner_dev = Runner.new(:environment => dev, :project => phpApp).execute
```

## Setup

### generate a ssh key

```
ssh-keygen -t rsa -b 4096 -f $PWD/id_rsa
```

### ensure .ssh exists

```
ssh root@54.158.155.138 "mkdir ~/.ssh"
```

### transfer key to target host for control

```
hosts=( IPADDRESS1 IPADDRESS2 )

for i in "${hosts[@]}"
do
  scp id_rsa.pub root@$i:~/.ssh/authorized_keys
done
```

### verify access to server without prompting for password

```
ssh -i id_rsa root@54.158.155.138
```

## run the program

```
ruby org_project.rb
```

# TODO

* Add support for detecting if command is needed before executing (a fetch of information before running?)
* Querying of hosts by role
* Add SSH parallel execution of commands
* Add test attribute for tasks to find out if they need to be run or not