class RefreshHackatimeStatsJob < ApplicationJob
  queue_as :default

  def perform(user_id, options = {})
    user = User.find_by(id: user_id)
    return unless user&.has_hackatime

    query_params = { user: user.slack_id }
    query_params[:from] = options[:from].to_s if options[:from]
    query_params[:to] = options[:to].to_s if options[:to]

    uri = URI("https://hackatime.hackclub.com/api/summary")
    uri.query = URI.encode_www_form(query_params)

    response = Faraday.get(uri.to_s)
    return unless response.success?

    result = JSON.parse(response.body)

    stats = user.hackatime_stat || user.build_hackatime_stat
    stats.update(data: result, last_updated_at: Time.current)
  end
end
