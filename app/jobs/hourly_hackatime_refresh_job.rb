class HourlyHackatimeRefreshJob < ApplicationJob
  queue_as :default

  def perform
    users = User.where(has_hackatime: true).distinct

    from = "2025-05-16"
    to = Date.today.strftime("%Y-%m-%d")

    users.find_each do |user|
      RefreshHackatimeStatsJob.perform_later(user.id, from: from, to: to)
    end
    puts "Hourly Hackatime refresh job performed for #{users.count} users"
    message = "Hourly Hackatime refresh job performed for #{users.count} users"

    begin
      client = Slack::Web::Client.new(token: ENV["SLACK_BOT_TOKEN"])
      puts "Sending Slack message: #{message}"
      client.chat_postMessage(
        channel: "C08TRKC44UU",
        text: message,
        as_user: true
      )
    rescue Slack::Web::Api::Errors::SlackError => e
      Rails.logger.error("Failed to send Slack message: #{e.message}")
    end
  end
end
