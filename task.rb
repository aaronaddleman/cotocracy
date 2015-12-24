require 'logger'
require 'open3'

class Task
  attr_accessor :name, :type, :command, :status

  def initialize(opts={})
    @name = opts[:name]
    @command = opts[:command]
  end

  def add_command(command)
    @command = command
  end

end
