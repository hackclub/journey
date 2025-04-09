class Project < ApplicationRecord
  belongs_to :user
  has_many :updates, dependent: :destroy
  has_many :project_follows, dependent: :destroy
  has_many :followers, through: :project_follows, source: :user

  validates :title, :description, :category, presence: true

  validates :readme_link, :demo_link, :repo_link, :banner,
    format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" },
    allow_blank: true

  validates :user_id, uniqueness: { message: "can only have one project" }

  validates :category, inclusion: { in: %w[Software Hardware], message: "%{value} is not a valid category" }

  after_initialize :set_default_rating, if: :new_record?

  private

  def set_default_rating
    self.rating ||= 1100
  end
end
