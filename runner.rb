require 'logger'
require 'open3'

class Runner 
  attr_accessor :environment, :log_file

  #shell to be used
  BASH_PATH = "/bin/bash"


  def initialize(opts={})
    @environment = opts[:environment] || nil
    @logfile = Logger.new(opts[:log_file]) || Logger.new('log_file.log')
    @print = Logger.new(STDOUT)
  end

  # allow executing on remote host
  def execute(command)
    @environment.instances.each do |instance|
      @logfile.info("-----------------------")
      @logfile.info("executing: '#{command}'")
      @logfile.info("for node: '#{instance}'")
      # block for connecting to instance via ssh and passing the command from the task
      bashremote = lambda do |command|
        Open3.popen3("ssh -i id_rsa root@#{instance} #{BASH_PATH}") do |stdin, stdout, stderr|
          stdin.puts command
          stdin.close_write
          @print.info( "\n" + stdout.read)
          @logfile.info(stdout.read)
          @logfile.error(stderr.read)
        end
      end

      # if the command has a substitution, replace the token from the selected environment's variables
      if command.match(/%%(.*)%%/)
        command.match(/%%(.*)%%/).captures.each do |substrings|
          # if the environment is missing a variable, raise an error
          begin
            command = command.gsub(/%%.*%%/, @environment.variables[substrings])
          rescue => e
            raise "'#{substrings}' is not defined in '#{@environment.name}'"
          end
        end
      end

      # log the command
      puts "running #{command} @ #{instance}"
      # run the command
      bashremote["#{command}"]
      
      @logfile.info("-----------------------")
    end

  end
end