require 'logger'
require 'open3'

class Runner 
  attr_accessor :environment, :log_file

  def initialize(opts={})
    @environment = opts[:environment] || nil
    @logfile = Logger.new(opts[:log_file]) || Logger.new('log_file.log')
    @print = Logger.new(STDOUT)
  end

  #shell
  BASH_PATH = "/bin/bash"

  def execute(command)
    @environment.instances.each do |instance|
      @logfile.info("-----------------------")
      @logfile.info("executing: '#{command}'")

      bashremote = lambda do |command|
        Open3.popen3("ssh -i id_rsa root@#{instance} #{BASH_PATH}") do |stdin, stdout, stderr|
          stdin.puts command
          stdin.close_write
          @print.info( "\n" + stdout.read)
          @logfile.info(stdout.read)
          @logfile.error(stderr.read)
        end
      end

      if command.match(/%%(.*)%%/)
        command.match(/%%(.*)%%/).captures.each do |substrings|
          begin
            command = command.gsub(/%%.*%%/, @environment.variables[substrings])
          rescue => e
            raise "'#{substrings}' is not defined in '#{@environment.name}'"
          end
        end
      end

      puts "running #{command} @ #{instance}"
      # bashremote["#{command}"]
      
      @logfile.info("-----------------------")
    end

  end
end