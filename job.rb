class Job
  attr_accessor :name, :tasks, :environment

  # initialize the jobs
  def initialize(opts={})
    @name = opts[:name]
    @tasks = opts[:tasks]
  end
end