class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :update_record, class_name: 'Update', foreign_key: 'update_id'
  
  validates :text, presence: true
end 