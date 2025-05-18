class AddIsDeletedToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :is_deleted, :boolean, default: false
  end
end
