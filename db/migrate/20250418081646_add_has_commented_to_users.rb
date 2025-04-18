class AddHasCommentedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :has_commented, :boolean, default: false
  end
end
