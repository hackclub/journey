class User < ApplicationRecord
    has_many :projects
    has_many :updates
  
    validates :slack_id, presence: true, uniqueness: true
    validates :email, :first_name, :middle_name, :last_name, :display_name, :timezone, presence: true
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  end
  