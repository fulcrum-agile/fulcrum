require "net/http"
require "uri"

class Mattermost
  def self.send(private_uri, project_channel, bot_username, message)
    Mattermost.new(private_uri, project_channel, bot_username).send(message)
  end

  def initialize(private_uri, project_channel = "off-topic", bot_username = "marvin")
    @private_uri = URI.parse(private_uri)
    @project_channel = project_channel
    @bot_username = bot_username
  end

  def send(text)
    Net::HTTP.post_form(@private_uri, {"payload" => payload(text)})
  end

  def payload(text)
    {
      username: @bot_username,
      channel: @project_channel,
      text: text
    }.to_json
  end
end
