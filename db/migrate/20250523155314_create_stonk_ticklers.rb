class CreateStonkTicklers < ActiveRecord::Migration[8.0]
  def change
    create_table :stonk_ticklers do |t|
      t.text :tickler, null: false
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
