class CreateUpdates < ActiveRecord::Migration[8.0]
  def change
    create_table :updates do |t|
      t.text :text
      t.string :attachment
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
