class IntegrationWorker
  include Sidekiq::Worker

  def perform(project_id, message)
    project = Project.find(project_id)
    project.integrations.each do |integration|
      if integration.kind == 'mattermost'
        Mattermost.send(integration.data['private_uri'],
                        integration.data['channel'],
                        integration.data['bot_username'],
                        message)
      end
    end
  end
end

