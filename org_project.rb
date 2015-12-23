require_relative 'project'
require_relative 'task'

phpApp = Project.new(:name => "The Hello World PHP App")
phpApp.description = "maintain content"
phpApp.tasks['install_php'] =  Task.new(:command, "apt-get install lamp-server")