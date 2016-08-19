require 'rails_helper'

describe IntegrationWorker do
  let(:integration) { FactoryGirl.create(:integration) }

  it "should send a message to mattermost" do
    expect(Mattermost).to receive(:send).with(
      integration.data['private_uri'],
      integration.data['channel'],
      integration.data['bot_username'],
      "Hello World")
    IntegrationWorker.new.perform(integration.project_id, "Hello World")
  end

  it "should read URI from ENV" do
    integration.data['private_uri'] = 'INTEGRATION_URI_MATTERMOST'
    expect(Mattermost).to receive(:send).with(
      'http://foo.com',
      integration.data['channel'],
      integration.data['bot_username'],
      "Hello World")
    IntegrationWorker.new.perform(integration.project_id, "Hello World")
  end
end
