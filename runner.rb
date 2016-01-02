require 'logger'
require 'open3'

class Runner 
  attr_accessor :environment, :log_file, :project, :commands

  #shell to be used
  BASH_PATH = "/bin/bash"
  #root password
  ROOTPW = "foobarbaz"


  def initialize(opts={})
    @environment = opts[:environment] || nil
    @commands = Array.new
    @project = process_project(opts[:project]) || nil
    @logfile = Logger.new(opts[:log_file]) || Logger.new('log_file.log')
    @print = Logger.new(STDOUT)
  end

  # def add_command(command)
  #   self.commands  =  "#{command}"
  # end

  def process_project(project)
    extracted_commands = []
    project.jobs.each do |id,job|
      job.tasks.each do |task|
        if task.command.match(/%%(.*)%%/)
          task.command.match(/%%(.*)%%/).captures.each do |substrings|
            begin
              task.command = task.command.gsub(/%%.*%%/, @environment.variables[substrings])
              # add_command(task.command)
            rescue => e
              raise "'#{substrings} is not defined in '#{environment.name}'"
            end
          end
        end
        extracted_commands << task.command
      end
    end

    # add extracted commands to attribute    
    @commands = extracted_commands
    # return the processed project 
    project
  end

  # execute commands
  def execute
    @commands.each do |command|
      @environment.instances.each do |instance|
      @logfile.info("-----------------------")
      @logfile.info("executing: '#{command}'")
      @logfile.info("for node: '#{instance}'")

      # create variable for capturing output or error
      captured_stdout = ''
      captured_stderr = ''

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

      # log the command
      puts "running #{command} @ #{instance}"
      # run the command
      bashremote["#{command}"]
      
      @logfile.info("-----------------------")
    end

    end
  end

  # possible idea to execute all commands on one line, but really bad for debugging
  def exec_bulk
    command = @commands.join(" && ")

    @environment.instances.each do |instance|

      @logfile.info("-----------------------")
      @logfile.info("executing: '#{command}'")
      @logfile.info("for node: '#{instance}'")

      # create variable for capturing output or error
      captured_stdout = ''
      captured_stderr = ''

      # block for connecting to instance via ssh and passing the command from the task
      bashremote = lambda do |command|
        Open3.popen3("ssh -i id_rsa root@#{instance} #{BASH_PATH}") do |stdin, stdout, stderr|
          stdin.puts command
          stdin.close_write
          puts stdout.read
          @print.info( "\n" + stdout.read)
          @logfile.info(stdout.read)
          @logfile.error(stderr.read)
        end
      end

      bashremote["#{command}"]
    end

    # puts "got:"
    # puts command.inspect
    # Open3.pipeline(commands)
  end
end