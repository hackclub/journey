class CreateVotes < ActiveRecord::Migration[7.1]
    def change
        create_table :votes do |t|
            t.references :user, null: false, foreign_key: true
            t.references :project, null: false, foreign_key: true
            t.text :explanation, null: false

            t.timestamps
        end

        add_index :votes, [ :user_id, :project_id ], unique: true
    end
end
