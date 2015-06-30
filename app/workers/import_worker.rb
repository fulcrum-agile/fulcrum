class ImportWorker
  include Sidekiq::Worker

  def perform(job_id, project_id)
    Rails.cache.write(job_id, nil)
    @project = Project.friendly.find(project_id)
    # Do not send any email notifications during the import process
    @project.suppress_notifications = true
    Project.transaction do
      @stories = @project.stories.from_csv(open(@project.import.fullpath).read)
      Rails.cache.write(job_id, { stories: @stories, errors: nil },
                        time_to_idle: 1.minute, timeToLive: 1.hour)
    end
  rescue => e
    Rails.cache.write(job_id, { stories: [], errors: e })
  end
end
