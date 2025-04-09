class AddCategoryToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :category, :string
  end
end
