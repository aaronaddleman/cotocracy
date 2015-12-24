class Job
  attr_accessor :name, :tasks, :environment

  def initialize(opts={})
    @name = opts[:name]
    @tasks = opts[:tasks]
    @environment = opts[:environment]
  end
end