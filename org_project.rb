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

RESOLVE_CONF = <<-eos
nameserver 8.8.8.8
nameserver 8.8.4.4
eos

SSHPUBKEY = <<eos
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD1dYX3Zbwa32fIaRKTpZb6eVLsJaNIOKAxN2U4jltbP65qjobJz2IUCNW/9CiemuLpp1HPq7rBravVoYo8JbrYdEmeD2AwTQMfoWQOLTtKDesHlwqH1sfjiV9UKyt+2qJ/lN5hKAjnhNWRs6B/g3iEwRQ7xDdSgrVVjP2zeR2VdteLN04zTUQid9Ec3wbjYLTZG2/hEseHwQ2JGXQgHt/UU+yTGFdO6NO5NryF2i92VnZ7tJg3ghpUBY2cI/eCGuf6rtC2mn4qGPMcLH6XymhZz0qNZ/+pqmKrhnu03CaZ6OMXqtaBgU1eFsp8KjimuFM4a2Y7/+N2eDbihY+a6w+nCCu/0ZIOdzm9sOOHwueeLuYBf0TYHnKbdpSNR8Di0EFiQJ+yNjyVXe1pqo8c2gXDxqVhyz8sjXBhgCGjwyZ0EQijkN5CbEGccxAmGfl/tIdMXlxx5PZMQpU+wVI2FVk/wonrXvdleT68T6c94ZRMyXzL+25gf9lBkKf/yGQjbOD1Uo8wHFbDabEiSjWcsBVvJ9/flBo2mMU8PeXBAiF43lOVc/B0D1sowkxafvhRSIHb15r4z9dHbxs/FWjeEAGIsImz+r5TMDn0RHk1tAZ7mzAlEAPHtefnmpAchZ/N033vGwEtGy6I1b5IC5c7b2JnUyY36TE/bru8YZ5wKGnAnw==
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


# add broken environment
broken = Environment.new(:name => "broken", :type => :production)
broken.add_variable(:keyname => "appdir", :role => "path", :value => "/var/www/html")
broken.add_variable(:keyname => "appfile", :role => "content", :value => PHPAPP)
broken.add_variable(:keyname => "frontend1", :role => "instance", :value =>  {:fqdn => "frontend-001.internal.dev", :ipaddress => "54.145.229.14"})
broken.add_variable(:keyname => "dns", :role => "content", :value => RESOLVE_CONF)
broken.add_variable(:keyname => "ssh", :role => "content", :value => SSHPUBKEY)

test = Environment.new(:name => "broken", :type => :production)
test.add_variable(:keyname => "appdir", :role => "path", :value => "/var/www/html")
test.add_variable(:keyname => "appfile", :role => "content", :value => PHPAPP)
test.add_variable(:keyname => "frontend1", :role => "instance", :value =>  {:fqdn => "frontend-001.internal.dev", :ipaddress => "10.0.1.172"})

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

# fix issues
fix_issues = [
  # kill the process with signal SIGKILL to release the file for deletion
  Task.new(:name => "stop service with open files marked for deletion", :command => "kill -SIGKILL `lsof -nP +L1 | awk '{print $2}' | tail -1`"),
  # create remote .ssh/authorized_keys
  Task.new(:name => "make .ssh", :command => "mkdir /root/.ssh"),
  Task.new(:name => "create authorized_keys", :command => "echo -n '%%ssh-content%%' > /root/.ssh/authorized_keys"),
  Task.new(:name => "set permissions", :command => "chmod 600 /root/.ssh && /root/.ssh/authorized_keys"),
  # dns issue not working correctly
  Task.new(:name => "populate the resolve.conf file with correct entries", :command => "echo -n '%%dns-content%%' > /etc/resolv.conf"),
  Task.new(:name => "kill process listening on port 80", :command => "kill -SIGKILL `netstat -tulpn | grep ':80' | awk '{print $7}' | awk -F\/ '{print $1}'`")
]


# add a job for installation using installation_tasks and dev environment variables
install_deps = Job.new(:name => 'install deps', 
                       :tasks => installation_tasks)

fix_broken_host = Job.new(:name => 'fix issues',
                          :tasks => fix_issues)

# add tasks to project
phpApp.add_job(fix_broken_host)
phpApp.add_job(install_deps)

# create runner object
# runner_prod = Runner.new(:environment => prod, :project => phpApp)
# runner_dev = Runner.new(:environment => dev, :project => phpApp)
runner_broken = Runner.new(:environment => broken, :project => phpApp).execute
# runner_test = Runner.new(:environment => test, :project => phpApp)