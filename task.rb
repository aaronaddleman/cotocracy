require 'logger'
require 'open3'

class Task
  attr_accessor :name, :type, :command, :status

  # associate the task with the options
  def initialize(opts={})
    @name = opts[:name]
    @command = opts[:command]
  end

  def add_localfile(opts={})
    path = opts[:path]
  end
end
