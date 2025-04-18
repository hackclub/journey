class SendSlackDmJob < ApplicationJob
  queue_as :default

  def perform(user_id, message)
    client = Slack::Web::Client.new(token: ENV['SLACK_BOT_TOKEN'])
    
    response = client.conversations_open(users: user_id)
    channel_id = response.channel.id
    
    client.chat_postMessage(
      channel: channel_id,
      text: message,
      as_user: true
    )
  rescue Slack::Web::Api::Errors::SlackError => e
    Rails.logger.error("Failed to send Slack DM: #{e.message}")
  end
end 