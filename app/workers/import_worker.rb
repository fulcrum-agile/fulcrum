require 'dalli'
class ImportWorker
  include Sidekiq::Worker

  MEMCACHED_POOL = ConnectionPool.new(:size => 10, :timeout => 3) do
    if ENV["MEMCACHIER_SERVERS"].present?
      Dalli::Client.new(ENV["MEMCACHIER_SERVERS"].split(","),
        :username => ENV["MEMCACHIER_USERNAME"],
        :password => ENV["MEMCACHIER_PASSWORD"],
        :failover => true,
        :socket_timeout => 1.5,
        :socket_failure_delay => 0.2,
        :value_max_bytes => 10485760)
    else
      Dalli::Client.new
    end
  end

  def perform(job_id, project_id)
    @project = Project.friendly.find(project_id)

    # Do not send any email notifications during the import process
    @project.suppress_notifications = true

    csv_body = open(@project.import.fullpath).read
    csv_body.force_encoding("utf-8")
    Project.transaction do
      @stories = @project.stories.from_csv(csv_body)
      invalid_stories = @stories.reject(&:valid?).map do |s|
        { title: s.title, errors: s.errors.full_messages.join(', ') }
      end
      @project.import = nil # erase the attachinary file
      set_cache(job_id, { invalid_stories: invalid_stories, errors: nil })
    end
  rescue => e
    set_cache(job_id, { invalid_stories: [], errors: e })
  end

  private
    def set_cache(key, value)
      MEMCACHED_POOL.with { |dalli| dalli.set(key, value) }
    end
end
