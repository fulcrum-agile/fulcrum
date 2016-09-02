require 'dalli'
class ImportWorker
  include Sidekiq::Worker

  MEMCACHED_POOL = ConnectionPool.new(size: 10, timeout: 3) do
    if ENV["MEMCACHIER_SERVERS"].present?
      Dalli::Client.new(ENV["MEMCACHIER_SERVERS"].split(","),
        username: ENV["MEMCACHIER_USERNAME"],
        password: ENV["MEMCACHIER_PASSWORD"],
        failover: true,
        socket_timeout: 1.5,
        socket_failure_delay: 0.2,
        value_max_bytes: 10485760)
    else
      Dalli::Client.new
    end
  end

  def perform(job_id, project_id)
    project = setup_project(project_id)

    csv_body = open(project.import.fullpath).read
    csv_body.force_encoding("utf-8")
    Project.transaction do
      stories = project.stories.from_csv(csv_body)
      invalid_stories = stories.reject(&:valid?).map do |s|
        { title: s.title, errors: s.errors.full_messages.join(', ') }
      end
      project.import = nil # erase the attachinary file
      set_cache(job_id, { invalid_stories: invalid_stories, errors: nil })
      fix_project_start_date(project)
    end
  rescue => e
    set_cache(job_id, { invalid_stories: [], errors: e.message })
  end

  def setup_project(project_id)
    Project.friendly.find(project_id).tap do |project|
      # Do not send any email notifications during the import process
      project.suppress_notifications = true
    end
  end

  def fix_project_start_date(project)
    oldest_story = project.stories.where.not(accepted_at: nil).order(:accepted_at).first
    if project.start_date > oldest_story.accepted_at
      project.update_attributes(start_date: oldest_story.accepted_at)
    end
  end

  def self.new_job_id
    "import_upload/#{SecureRandom.base64(15).tr('+/=', 'xyz')}"
  end

  private
    def set_cache(key, value)
      MEMCACHED_POOL.with { |dalli| dalli.set(key, value) }
    end
end
