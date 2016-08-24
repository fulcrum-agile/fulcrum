class ProjectUpdaterService

  def self.save(*args)
    new(*args).save
  end

  def initialize(project, params = {})
    @project = project
    @params = params.to_hash
  end

  def save
    ActiveRecord::Base.transaction do
      if project.new_record?
        project.save!
      else
        project.update_attributes!(params)
      end
    end
    project
  rescue ActiveRecord::RecordInvalid
    return false
  end

  private

  attr_reader :project, :params
end
