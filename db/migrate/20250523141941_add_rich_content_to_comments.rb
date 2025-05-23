class AddRichContentToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :rich_content, :jsonb
  end
end
