# a project requires the following
## tasks (defines the work to be executed)
## environments (holds keys+values about environments)
## jobs (takes the task and the environment and executes the work)

class Project
  attr_accessor :name, :description, :created_at, :jobs

  # create project
  def initialize(name)
    @name = name
    @jobs = Hash.new
    @created_at = Time.now
  end

  # get the total number of jobs for index number
  def last_job_number
    @jobs.length
  end

  # add a job with an index number
  def add_job(item)
    @jobs[last_job_number] = item
  end
end