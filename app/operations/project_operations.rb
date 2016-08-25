class ProjectOperations
  class Create
    def self.run(*args)
      new(*args).run
    end

    def initialize(model)
      @model = model
    end

    def run
      ActiveRecord::Base.transaction do
        operate!
      end
      return model
    rescue ActiveRecord::RecordInvalid
      return false
    end

    protected

    attr_reader :model

    def operate!
      model.save!
    end
  end

  class Update < Create
    def initialize(model, params)
      @params = params.to_hash
      super(model)
    end

    protected

    attr_reader :params

    def operate!
      model.update_attributes!(params)
    end
  end

  class Destroy < Create
    protected

    def operate!
      # because of dependent => destroy it can take a very long time to delete a project
      # FIXME instead of deleting we should add something like Papertrail to
      # implement an 'Archive'-like feature instead
      if Rails.env.production?
        model.delay.destroy
      else
        model.destroy!
      end
    end
  end
end
