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
      Activity.create(project: fetch_project, user: current_user, action: self.class.name.downcase, subject: model)
    end
  end

  class Create
    include ActivityRecording

    def self.run(*args)
      new(*args).run
    end

    def initialize(model, current_user)
      @model = model
      @current_user = current_user
    end

    def run
      ActiveRecord::Base.transaction do
        before_save
        operate!
        after_save
      end
      return model
    rescue ActiveRecord::RecordInvalid
      return false
    end

    protected

    attr_reader :model, :current_user

    def before_save
    end

    def after_save
    end

    def operate!
      model.save!
    end
  end

  class Update < BaseOperations::Create
    def initialize(model, params, current_user)
      @params = params.to_hash
      super(model, current_user)
    end

    protected

    attr_reader :params

    def operate!
      model.attributes = params
      changes = model.changed_attributes
      model.save!
      model.instance_variable_set('@changed_attributes', changes)
    end
  end

  class Destroy < BaseOperations::Create
    protected

    def operate!
      model.destroy!
    end
  end
end
