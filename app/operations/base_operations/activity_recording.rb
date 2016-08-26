module BaseOperations
  module ActivityRecording
    def fetch_project
      case model
      when Project
        model
      when Story
        model.project
      when Note, Task
        model.story.project
      end
    end

    def create_activity
      Activity.create!(project: fetch_project, user: current_user, action: self.class.name.split("::").last.downcase, subject: model)
    end
  end
end
