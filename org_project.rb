require_relative 'project'
require_relative 'task'
require_relative 'job'
require_relative 'env'
require_relative 'runner'

# define a new project name
phpApp = Project.new(:name => "The Hello World PHP App")
# add the description
phpApp.description = "Maintain Content for HelloWorld behind Load Balancer"

# content
PHPAPP = <<-eos
<?php
header("Content-Type: text/plain");
echo "Hello, world!\n";
eos

# add dev environment
dev = Environment.new(:name => "development", :type => :development)
dev.add_variable(:keyname => "appdir", :role => "path", :value => "/var/www/html")
dev.add_variable(:keyname => "appfile", :role => "content", :value => PHPAPP)
dev.add_variable(:keyname => "frontend1", :role => "instance", :value =>  {:fqdn => "frontend-002.internal.dev", :ipaddress => "10.0.1.172"})

# add prod environment
prod = Environment.new(:name => "production", :type => :production)
prod.add_variable(:keyname => "appdir", :role => "path", :value => "/var/www/html")
prod.add_variable(:keyname => "appfile", :role => "content", :value => PHPAPP)
prod.add_variable(:keyname => "frontend1", :role => "instance", :value =>  {:fqdn => "frontend-001.internal.dev", :ipaddress => "54.158.155.138"})
prod.add_variable(:keyname => "frontend2", :role => "instance", :value =>  {:fqdn => "frontend-002.internal.dev", :ipaddress => "54.92.232.190"})


# add installation tasks
installation_tasks = [
  Task.new(:name => "install_lamp_apt_update", :command => "apt-get update"),
  Task.new(:name => "install_apache", :command => "apt-get install apache2 --assume-yes"),
  Task.new(:name => "install_php", :command => "apt-get install php5 libapache2-mod-php5 php5-mcrypt --assume-yes"),
  Task.new(:name => "start_apache", :command => "service apache start"),
  Task.new(:name => "create_content", :command => "echo -n '%%appfile-content%%' > /var/www/html/index.php"),
  Task.new(:name => "remote_file", :command => "rm /var/www/html/index.html")
]

# add config_tasks
config_tasks = [
  Task.new(:name => "create logging directory", :command => "mkdir -p %%appdir-path%%/log")
]

# add a job for installation using installation_tasks and dev environment variables
install_deps = Job.new(:name => 'install deps', 
                       :tasks => installation_tasks)


# add tasks to project
phpApp.add_job(install_deps)

# create runner object
runner_prod = Runner.new(:environment => prod)
runner_dev = Runner.new(:environment => dev)

# execute tasks
phpApp.jobs.each do |id,job|

  job.tasks.each do |task|
    runner_prod.execute(task.command)
  end

end