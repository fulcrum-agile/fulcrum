class TaskCreationService
  def self.create(*args)
    new(*args).create
  end

  def initialize(task)
    @task = task
  end

  def create
    ActiveRecord::Base.transaction do
      @task.save!
      @task.story.changesets.create!
    end
    @task
  rescue ActiveRecord::RecordInvalid
    return false
  end
end
