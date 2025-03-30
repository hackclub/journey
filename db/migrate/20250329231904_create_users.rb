class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :slack_id
      t.string :email
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :display_name
      t.string :timezone

      t.timestamps
    end
  end
end
