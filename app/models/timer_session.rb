class TimerSession < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :update_record, class_name: "Update", foreign_key: "update_id", optional: true

  enum :status, { running: 0, paused: 1, stopped: 2 }

  validates :user, :project, :started_at, :status, presence: true
  validate :validate_no_changes_if_stopped, on: :update
  validate :validate_minimum_duration, on: :update

  before_destroy :prevent_destroy_if_stopped

  MINIMUM_DURATION = 300 # 5 minutes

  private

  def validate_no_changes_if_stopped
    if status_was == "stopped" && changed? && (changed - [ "update_id" ]).present?
      errors.add(:base, "Stopped timer sessions cannot be modified")
    end
  end

  def validate_minimum_duration
    if status_changed? && status == "stopped" && net_time < MINIMUM_DURATION
      errors.add(:base, "Timer sessions must be at least 5 minutes long")
    end
  end

  def prevent_destroy_if_stopped
    if stopped?
      errors.add(:base, "Stopped timer sessions cannot be deleted")
      throw :abort
    end
  end
end
