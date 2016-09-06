module TeamOperations

  class Create < BaseOperations::Create
    def create_activity
      # bypass (no current_user)
    end
  end

  class Update < BaseOperations::Update
    def create_activity
      # bypass (no current_project)
    end
  end

  class Destroy < BaseOperations::Destroy
    def create_activity
      # bypass (no current_project)
    end

    protected

    def operate!
      # do not delete from the database, just mark as archived
      model.update_attributes!(archived_at: Time.current)
    end
  end

end
