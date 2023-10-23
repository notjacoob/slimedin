class AddNamesToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :first_name, :text
    add_column :addresses, :last_name, :text
  end
end
