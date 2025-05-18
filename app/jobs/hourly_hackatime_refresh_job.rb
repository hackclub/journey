class HourlyHackatimeRefreshJob < ApplicationJob
  queue_as :default

  def perform
    users = User.where(has_hackatime: true).distinct

    users.find_each do |user|
      RefreshHackatimeStatsJob.perform_later(user.id)
    end

    HourlyHackatimeRefreshJob.set(wait: 1.hour).perform_later
  end

  # Init recurring job if it's not already scheduled
  def self.schedule_if_needed
    return if SolidQueue::Job.where(class_name: self.name).where("finished_at IS NULL").exists?

    perform_later
  end
end
