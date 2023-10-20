class RenameAddressColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :addresses, :type, :address_type
  end
end
