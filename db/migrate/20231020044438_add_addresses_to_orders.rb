class AddAddressesToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :billing_address
    add_reference :orders, :shipping_address
  end
end
