class HackatimeStat < ApplicationRecord
  belongs_to :user

  def total_seconds_for_project(project)
    return 0 if data.blank? || !data["projects"].is_a?(Array)

    project_keys = project.hackatime_keys
    return 0 if project_keys.blank?

    data["projects"].sum do |hackatime_project|
      if project_keys.include?(hackatime_project["key"])
        hackatime_project["total"].to_i
      else
        0
      end
    end
  end

  def seconds_since_last_update
    return 0 unless last_updated_at
    (Time.current - last_updated_at).to_i
  end

  def can_post_for_project?(project, required_seconds)
    total_seconds = total_seconds_for_project(project)
    total_seconds >= required_seconds
  end

  def time_since_last_update_for_project(project)
    last_update = project.updates.where.not(last_hackatime_time: nil).order(created_at: :desc).first
    return total_seconds_for_project(project) unless last_update

    total_seconds_for_project(project) - last_update.last_hackatime_time
  end

  def can_post_for_project_since_last_update?(project, required_seconds = 300) # 5 minutes
    return false unless user.has_hackatime? && project.hackatime_keys.present?

    time_since_last = time_since_last_update_for_project(project)
    time_since_last >= required_seconds
  end

  def seconds_needed_since_last_update(project, required_seconds = 300)
    return required_seconds unless user.has_hackatime?

    time_since_last = time_since_last_update_for_project(project)
    [ required_seconds - time_since_last, 0 ].max
  end

  def has_enough_time_since_last_update?(project, required_seconds = 300)
    return false unless user.has_hackatime? && project.hackatime_keys.present?

    can_post_for_project_since_last_update?(project, required_seconds)
  end
end
