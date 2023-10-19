class AddAdministrators < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :administrator, :boolean, default: false
  end
end
