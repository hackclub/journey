class Vote < ApplicationRecord
    belongs_to :user
    belongs_to :project

    validates :explanation, presence: true, length: { minimum: 10 }
    validates :user_id, uniqueness: { scope: :project_id, message: "has already voted for this project" }
end
