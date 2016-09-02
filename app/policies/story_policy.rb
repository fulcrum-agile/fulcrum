class StoryPolicy < ApplicationPolicy
  def show?
    context.current_project.stories.find(record)
  end

  def done?
    update?
  end

  def backlog?
    update?
  end

  def in_progress?
    update?
  end

  class Scope < Scope
    def resolve
      context.current_project.stories
    end
  end
end

