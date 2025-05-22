class DailyStonkReport < ApplicationRecord
  validates :date, presence: true, uniqueness: true
  validates :report, presence: true

  def self.for(day = Date.current)
    find_by(date: day)
  end
end
