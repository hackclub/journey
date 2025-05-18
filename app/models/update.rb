class Update < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :comments, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :timer_sessions, foreign_key: "update_id", dependent: :nullify

  attr_accessor :timer_session_id

  validates :text, presence: true

  # Attachment is a #cdn link
  validates :attachment, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }, allow_blank: true

  # Validates if only MD changes are made
  validate :only_formatting_changes, on: :update

  validate :updates_not_locked, on: :create
  validate :validate_timer_session_not_linked, on: :create
  validate :validate_timer_session_required, on: :create
  validate :validate_hackatime_time_since_last_update, on: :create

  after_commit :sync_to_airtable, on: [ :create, :update ]
  after_commit :associate_timer_session, on: :create
  after_destroy :delete_from_airtable

  def formatted_text
    ApplicationController.helpers.markdown(text)
  end

  private

  def validate_timer_session_required
    has_hackatime = project.hackatime_project_keys.present? &&
                    project.user.has_hackatime? &&
                    project.user.hackatime_stat&.has_enough_time_since_last_update?(project)

    if timer_session_id.blank? && !has_hackatime
      errors.add(:timer_session_id, "You need to track time with Timer Session or Hackatime")
    end
  end

  def validate_timer_session_not_linked
    return unless timer_session_id.present?

    timer_session = TimerSession.find_by(id: timer_session_id)
    if timer_session && timer_session.update_id.present?
      errors.add(:timer_session_id, "This timer session is already linked to another update")
    end
  end

  def validate_hackatime_time_since_last_update
    return unless project.hackatime_project_keys.present? && project.user.has_hackatime?
    return if timer_session_id.present?

    unless project.user.hackatime_stat&.has_enough_time_since_last_update?(project)
      seconds_needed = project.user.hackatime_stat&.seconds_needed_since_last_update(project) || 300
      errors.add(:base, "You need to spend more time on this project before posting an update. #{ActionController::Base.helpers.format_seconds(seconds_needed)} more needed since your last update.")
    end
  end

  def associate_timer_session
    return unless timer_session_id.present?

    timer_session = project.timer_sessions.find_by(id: timer_session_id)
    return unless timer_session
    return if timer_session.update_id.present?

    timer_session.update(update_record: self)
  end

  def updates_not_locked
    if ENV["UPDATES_STATUS"] == "locked"
      errors.add(:base, "Posting updates is currently locked")
    end
  end

  def only_formatting_changes
    if text_changed? && persisted?
      original_stripped = strip_formatting(text_was)
      new_stripped = strip_formatting(text)

      if original_stripped != new_stripped
        errors.add(:text, "You can only modify formatting (markdown, spaces, line breaks), not the content")
      end
    end
  end

  def strip_formatting(text)
    return "" if text.nil?
    text.gsub(/[\s\n\r\t\*\_\#\~\`\>\<\-\+\.\,\;\:\!\?\(\)\[\]\{\}]/i, "").downcase
  end

  def sync_to_airtable
    SyncUpdateToAirtableJob.perform_later(id)
  end

  def delete_from_airtable
    DeleteUpdateFromAirtableJob.perform_later(id)
  end
end
