class Project < ApplicationRecord
  belongs_to :user
  has_many :updates
  has_many :project_follows
  has_many :followers, through: :project_follows, source: :user
  has_many :stonks
  has_many :stakers, through: :stonks, source: :user

  has_many :won_votes, class_name: "Vote", foreign_key: "winner_id"
  has_many :lost_votes, class_name: "Vote", foreign_key: "loser_id"

  has_many :timer_sessions

  default_scope { where(is_deleted: false) }

  def self.with_deleted
    unscoped
  end

  def self.find_with_deleted(id)
    with_deleted.find(id)
  end

  validates :title, :description, :category, presence: true

  validates :readme_link, :demo_link, :repo_link, :banner,
    format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" },
    allow_blank: true

  validates :category, inclusion: { in: [ "Software", "Hardware", "Both Software & Hardware", "Something else" ], message: "%{value} is not a valid category" }

  validate :cannot_change_category, on: :update

  before_save :filter_hackatime_keys

  before_save :remove_duplicate_hackatime_keys

  after_initialize :set_default_rating, if: :new_record?

  after_commit :sync_to_airtable, on: [ :create, :update ]

  def total_votes
    won_votes.count + lost_votes.count
  end

  def won_votes_count
    won_votes.count
  end

  def lost_votes_count
    lost_votes.count
  end

  def hackatime_total_time
    return 0 unless user.has_hackatime? && hackatime_project_keys.present?

    hackatime_project_keys.sum do |project_key|
      user.project_time_from_hackatime(project_key)
    end
  end

  def total_stonks
    stonks.sum(:amount)
  end

  def user_stonks(user)
    stonk = stonks.find_by(user: user)
    stonk ? stonk.amount : 0
  end

  def hackatime_keys
    hackatime_project_keys || []
  end

  private

  def set_default_rating
    self.rating ||= 1100
  end

  def cannot_change_category
    if category_changed? && persisted?
      errors.add(:category, "cannot be changed after project creation")
    end
  end

  def filter_hackatime_keys
    self.hackatime_project_keys = hackatime_project_keys.reject(&:blank?) if hackatime_project_keys
  end

  def remove_duplicate_hackatime_keys
    self.hackatime_project_keys = hackatime_project_keys.uniq if hackatime_project_keys
  end

  def sync_to_airtable
    SyncProjectToAirtableJob.perform_later(id)
  end
end
