class Stonk < ApplicationRecord
  DEFAULT_AMOUNT = 3 # Fixed amount of 3 dollars per stonk, but it'll be different for dreamland :smiling_face_with_3_hearts:

  belongs_to :user
  belongs_to :project

  validates :amount, presence: true, numericality: { equal_to: DEFAULT_AMOUNT }

  before_validation :set_default_amount, on: :create

  scope :today, -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :recent, -> { where(created_at: 24.hours.ago..Time.current) }
  scope :days_ago, ->(n) { where(created_at: (n+1).days.ago..n.days.ago) }

  def self.report
    per_bucket = Stonk
      .joins(:project)
      .group(
        'projects.title',
        'projects.description',
        'projects.category',
        'projects.is_shipped',
        'projects.rating',
        'projects.created_at'
      )
      .group("FLOOR(EXTRACT(EPOCH FROM (NOW() AT TIME ZONE 'UTC') - stonks.created_at) / 86400)::int")
      .sum(:amount)                               # {[title, desc, …, bucket] => sum}

    # 1. reshape so outer key = the six project attrs
    nested = per_bucket.each_with_object(Hash.new { |h, k| h[k] = {} }) do
      |((title, desc, cat, shipped, rating, proj_created, bucket), amt), h|
      key = [title, desc, cat, shipped, rating, proj_created]
      h[key][bucket] = amt
    end

    # 2.  order those projects by their total stonk amount (DESC)
    nested.sort_by { |_, buckets| -buckets.values.sum }.to_h

    nested
  end

  private

  def set_default_amount
    self.amount ||= DEFAULT_AMOUNT
  end
end
