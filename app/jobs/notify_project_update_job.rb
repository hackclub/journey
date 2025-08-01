class NotifyProjectUpdateJob < ApplicationJob
  queue_as :default

  def perform(update_id)
    update = Update.find(update_id)
    return unless update

    project = update.project
    update_author = update.user

    follower_slack_ids = project.project_follows.joins(:user).pluck("users.slack_id").compact
    stonk_slack_ids = project.stonks.joins(:user).pluck("users.slack_id").compact

    both_slack_ids = follower_slack_ids & stonk_slack_ids

    only_follower_slack_ids = follower_slack_ids - stonk_slack_ids
    only_stonk_slack_ids = stonk_slack_ids - follower_slack_ids

    both_slack_ids.each do |slack_id|
      message = "New update on a project you follow AND have stonked! :heart: :stonksss: Check it out at #{project_url(project)}! Show some love and engage with the author!"
      SendSlackDmJob.perform_later(slack_id, message)
    end

    only_follower_slack_ids.each do |slack_id|
      message = "New update on a project you follow! :heart: Check it out at #{project_url(project)}! Show some love and engage with the author!"
      SendSlackDmJob.perform_later(slack_id, message)
    end

    only_stonk_slack_ids.each do |slack_id|
      message = "New update on a project you have stonked! :stonksss: Check it out at #{project_url(project)}! Show some love and engage with the author!"
      SendSlackDmJob.perform_later(slack_id, message)
    end
  end

  private

  def project_url(project)
    Rails.application.routes.url_helpers.project_url(project, host: ENV["APP_HOST"])
  end
end
