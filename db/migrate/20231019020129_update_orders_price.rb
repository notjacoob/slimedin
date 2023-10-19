class UpdateOrdersPrice < ActiveRecord::Migration[7.0]
  def change
    add_monetize :orders, :price
  end
end
