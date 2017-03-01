module TaskOperations
  class Create < BaseOperations::Create
    def after_save
      model.story.changesets.create!
    end
  end
end
