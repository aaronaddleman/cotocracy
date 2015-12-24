require 'logger'
require 'open3'

class Task
  attr_accessor :name, :type, :command, :status

  #logging
  LOGGER = Logger.new('log_file.log')  
  PRINT = Logger.new(STDOUT)
  #servers
  SERVER = "54.158.155.138"
  #shell
  BASH_PATH = "/bin/bash"

  def initialize(name, type, command)
    @name = name
    @type = type
    @command = command
  end

  def add_command(command)
    @command = command
  end

  def execute(command)
    LOGGER.info("-----------------------")
    LOGGER.info("executing: '#{command}'")

    bashremote = lambda do |command|
      Open3.popen3("ssh -i id_rsa root@#{SERVER} #{BASH_PATH}") do |stdin, stdout, stderr|
        stdin.puts command
        stdin.close_write
        PRINT.info( "\n" + stdout.read)
        LOGGER.info(stdout.read)
        LOGGER.error(stderr.read)
      end
    end

    bashremote["#{command}"]
  end
end

# t = Task.new()
# # testing package search
# t.execute("apt-cache search sinatra")
# # testing error output
# t.execute("nocommand")