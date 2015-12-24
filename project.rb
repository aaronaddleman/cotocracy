# a project requires the following
## tasks (defines the work to be executed)
## environments (holds keys+values about environments)
## jobs (takes the task and the environment and executes the work)

class Project
  attr_accessor :name, :description, :created_at, :jobs

  def initialize(name)
    @name = name
    @jobs = Hash.new
    @created_at = Time.now
  end

  def last_job_number
    @jobs.length
  end

  def add_job(item)
    # item.tasks.each do |tasks|
    #   if tasks.command.match(/%%(.*)%%/)
    #     tasks.command.match(/%%(.*)%%/).captures.each do |substrings|
    #       tasks.command = tasks.command.gsub(/%%.*%%/, item.environment.variables[substrings])
    #     end
    #   end
    # end
    @jobs[last_job_number] = item
  end
end