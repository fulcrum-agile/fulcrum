module StoryOperations
  module LegacyFixes
    def fix_project_start_date
      return unless model.state_changed?
      # Set the project start date to today if the project start date is nil
      # and the state is changing to any state other than 'unstarted' or
      # 'unscheduled'
      # FIXME Make model method on Story
      if model.project && !model.project.start_date && !['unstarted', 'unscheduled'].include?(model.state)
        model.project.start_date = Date.current
      end
    end

    def fix_story_accepted_at
      # If a story's 'accepted at' date is prior to the project start date,
      # the project start date should be moved back accordingly
      if model.accepted_at_changed? && model.accepted_at && model.accepted_at < model.project.start_date
        model.project.start_date = model.accepted_at
      end
    end

    def apply_fixes
      fix_project_start_date
      fix_story_accepted_at
      model.project.save! if model.project.start_date_changed?
    end
  end
end
