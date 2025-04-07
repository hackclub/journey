class Project < ApplicationRecord
  belongs_to :user
  has_many :updates, dependent: :destroy
  validates :title, :description, :readme_link, :demo_link, :repo_link, :banner, presence: true
  validates :readme_link, :demo_link, :repo_link, :banner,
    format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }

  # Ensure rating has a default value of 1100
  after_initialize :set_default_rating, if: :new_record?

  private

  def set_default_rating
    self.rating ||= 1100
  end
end
