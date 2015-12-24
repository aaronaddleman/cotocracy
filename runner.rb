require 'logger'
require 'open3'

class Runner 
  attr_accessor :environment, :log_file

  def initialize(opts={})
    @environment = opts[:environment] || nil
    @logfile = Logger.new(opts[:log_file]) || Logger.new('log_file.log')
    @print = Logger.new(STDOUT)
  end

  #servers
  SERVER = "54.158.155.138"
  #shell
  BASH_PATH = "/bin/bash"

  def execute(command)
    @logfile.info("-----------------------")
    @logfile.info("executing: '#{command}'")

    bashremote = lambda do |command|
      Open3.popen3("ssh -i id_rsa root@#{SERVER} #{BASH_PATH}") do |stdin, stdout, stderr|
        stdin.puts command
        stdin.close_write
        @print.info( "\n" + stdout.read)
        @logfile.info(stdout.read)
        @logfile.error(stderr.read)
      end
    end

    # bashremote["#{command}"]
    puts "running #{command}"
    @logfile.info("-----------------------")
  end
end