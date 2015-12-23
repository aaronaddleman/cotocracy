# a project requires the following
## tasks (defines the work to be executed)
## environments (holds keys+values about environments)
## jobs (takes the task and the environment and executes the work)

class Project
  attr_accessor :name, :description, :created_at, :tasks

  def initialize(name)
    @name = name
    @tasks = Hash.new
    @created_at = Time.now
  end
end