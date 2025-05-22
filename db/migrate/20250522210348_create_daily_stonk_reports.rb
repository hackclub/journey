class CreateDailyStonkReports < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_stonk_reports do |t|
      t.text :report, null: false
      t.date :date, null: false

      t.timestamps
    end

    add_index :daily_stonk_reports, :date, unique: true
  end
end
