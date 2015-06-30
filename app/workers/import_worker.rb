class ImportWorker
  include Sidekiq::Worker

  MEMCACHED_POOL = ConnectionPool.new(:size => 10, :timeout => 3) do
                     Rails.cache.try(:dalli) || Dalli::Client.new
                   end

  def perform(job_id, project_id)
    set_cache(job_id, nil)
    @project = Project.friendly.find(project_id)

    # Do not send any email notifications during the import process
    @project.suppress_notifications = true

    Project.transaction do
      @stories = @project.stories.from_csv(open(@project.import.fullpath).read)
      set_cache(job_id, { stories: @stories, errors: nil })
    end
  rescue => e
    set_cache(job_id, { stories: [], errors: e })
  end

  private
    def set_cache(key, value)
      MEMCACHED_POOL.with { |dalli| dalli.set(key, value) }
    end
end
