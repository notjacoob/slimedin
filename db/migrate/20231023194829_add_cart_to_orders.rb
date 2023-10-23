class AddCartToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :cart
  end
end
