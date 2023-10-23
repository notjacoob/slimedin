class ReviseCart < ActiveRecord::Migration[7.0]
  def change
    remove_reference :carts, :order
    remove_column :carts, :products
  end
end
