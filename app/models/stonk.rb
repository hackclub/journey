class Stonk < ApplicationRecord
  DEFAULT_AMOUNT = 3 # Fixed amount of 3 dollars per stonk, but it'll be different for dreamland :smiling_face_with_3_hearts:

  belongs_to :user
  belongs_to :project

  validates :amount, presence: true, numericality: { equal_to: DEFAULT_AMOUNT }

  before_validation :set_default_amount, on: :create

  private

  def set_default_amount
    self.amount ||= DEFAULT_AMOUNT
  end
end
