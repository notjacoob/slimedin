class SwitchAddressStorageMethod < ActiveRecord::Migration[7.0]
  def change
    remove_column :addresses, :order_id
  end
end
