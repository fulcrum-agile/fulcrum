class IntegrationWorker
  include Sidekiq::Worker
  include Central::Support::MattermostHelper

  def perform(project_id, message)
    project = Project.find(project_id)
    project.integrations.
      select { |integration| integration.kind == 'mattermost' }.
      each   { |integration| send_mattermost(integration, message) }
  end
end
