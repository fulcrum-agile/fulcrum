class TaskPolicy < StoryPolicy
  def show?
    current_story.tasks.find_by_id(record.id)
  end

  class Scope < Scope
    def resolve
      if is_admin?
        current_story.tasks
      else
        if is_story_member?
          current_story.tasks
        else
          Task.none
        end
      end
    end
  end
end
