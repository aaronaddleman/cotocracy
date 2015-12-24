require_relative 'project'
require_relative 'task'
require_relative 'job'
require_relative 'env'

# define a new project name
phpApp = Project.new(:name => "The Hello World PHP App")
# add the description
phpApp.description = "maintain content"
# add the tasks
task_list = {
  "install_php" => Task.new("install_php", :install, "apt-get install lamp-server"),
  "install_content" => Task.new("install_content", :git, "git clone URL"),
  "start_helloworld" => Task.new("start_helloworld", :service, "service %PROJECTNAME% start")
}
# add environment
dev = Env.new(:name => "development", :type => :development)
dev.add_variable(:keyname => "content", :value => "hello world this is the php app")
dev.add_variable(:keyname => "instance", :value =>  {:fqdn => "frontend-001.internal.dev", :ipaddress => "54.158.155.138"}
dev.add_variable(:keyname => "instance", :value =>  {:fqdn => "frontend-002.internal.dev", :ipaddress => "54.92.232.190"}
# add a job
install_deps = Job.new(:name => "install_deps", :tasks => task_list, :env => dev )
# add tasks to project
phpApp.tasks = task_list
# execute tasks
phpApp.