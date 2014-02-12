class TaskObserver < ActiveRecord::Observer
  def after_create(task)
    task.story.changesets.create!
  end
end
