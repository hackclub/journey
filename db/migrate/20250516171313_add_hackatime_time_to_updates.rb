class AddHackatimeTimeToUpdates < ActiveRecord::Migration[8.0]
  def change
    add_column :updates, :last_hackatime_time, :integer
  end
end
