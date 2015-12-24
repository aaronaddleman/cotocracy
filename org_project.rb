require_relative 'project'
require_relative 'task'
require_relative 'job'
require_relative 'env'
require_relative 'runner'

# define a new project name
phpApp = Project.new(:name => "The Hello World PHP App")
# add the description
phpApp.description = "Maintain Content for HelloWorld behind Load Balancer"

# add environment
dev = Environment.new(:name => "development", :type => :development)
dev.add_variable(:keyname => "helloworld", :role => "content", :value => "hello world this is the php app")
dev.add_variable(:keyname => "appdir", :role => "path", :value => "/opt/helloworld")
dev.add_variable(:keyname => "frontend1", :role => "instance", :value =>  {:fqdn => "frontend-001.internal.dev", :ipaddress => "54.158.155.138"})
dev.add_variable(:keyname => "frontend2", :role => "instance", :value =>  {:fqdn => "frontend-002.internal.dev", :ipaddress => "54.92.232.190"})

# add installation tasks
installation_tasks = [
  Task.new(:name => "install_php", :command => "hostname"),
  Task.new(:name => "install_php", :command => "ls %%appdir-path%%"),
  Task.new(:name => "install_php", :command => "dig google.com")
]

# add config_tasks
config_tasks = [
  Task.new(:name => "create logging directory", :command => "mkdir %%appdir-path%%/log")
]

# add a job for installation using installation_tasks and dev environment variables
install_deps = Job.new(:name => 'install deps for dev', 
                       :tasks => installation_tasks, 
                       :environment => dev)

# add a job for configuration
config = Job.new(:name => 'configure application',
                 :tasks => config_tasks,
                 :environment => dev)

# add tasks to project
phpApp.add_job(install_deps)
phpApp.add_job(config)

# create runner object
runner = Runner.new()

# execute tasks
phpApp.jobs.each do |id,job|

  job.tasks.each do |task|
    runner.execute(task.command)
  end
end

# puts phpApp.jobs