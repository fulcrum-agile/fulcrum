module BaseOperations

  class Create
    def self.run(*args)
      new(*args).run
    end

    def initialize(model)
      @model = model
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

    attr_reader :model

    def before_save
    end

    def after_save
    end

    def operate!
      model.save!
    end
  end

  class Update < BaseOperations::Create
    def initialize(model, params)
      @params = params.to_hash
      super(model)
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
