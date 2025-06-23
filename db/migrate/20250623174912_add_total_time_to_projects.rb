class AddTotalTimeToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :total_time, :integer, default: 0, null: false
    add_index :projects, :total_time
  end
end
