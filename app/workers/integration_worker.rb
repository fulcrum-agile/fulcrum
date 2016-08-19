class IntegrationWorker
  include Sidekiq::Worker

  def perform(project_id, message)
    project = Project.find(project_id)
    project.integrations.each do |integration|
      if integration.kind == 'mattermost'
        Mattermost.send(real_private_uri(integration.data['private_uri'] ),
                        integration.data['channel'],
                        integration.data['bot_username'],
                        message)
      end
    end
  end

  private

  def real_private_uri(private_uri)
    if private_uri.starts_with? "INTEGRATION_URI"
      ENV[private_uri]
    else
      private_uri
    end
  end
end

