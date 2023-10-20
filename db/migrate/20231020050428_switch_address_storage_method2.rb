class SwitchAddressStorageMethod2 < ActiveRecord::Migration[7.0]
  def change
    remove_reference :addresses, :order
  end
end
