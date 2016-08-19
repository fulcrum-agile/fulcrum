require 'rails_helper'

describe Mattermost do
  let(:mattermost) { Mattermost.new("http://foo.com", "test-channel", "bot")}

  context '#payload' do
    it 'returns a JSON formatted payload' do
      expect(mattermost.payload("Hello World")).to eq("{\"username\":\"bot\",\"channel\":\"test-channel\",\"text\":\"Hello World\"}")
    end
  end

  context '#send' do
    it 'triggers a HTTP POST to send payload' do
      expect(Net::HTTP).to receive(:post_form)
      mattermost.send("hello")
    end
  end
end
