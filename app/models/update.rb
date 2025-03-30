class Update < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :text, presence: true

  # Attachment is a #cdn link
  validates :attachment, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }, allow_blank: true
end
