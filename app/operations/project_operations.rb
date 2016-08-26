module ProjectOperations

  class Create < BaseOperations::Create
  end

  class Update < BaseOperations::Update
  end

  class Destroy < BaseOperations::Destroy
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
