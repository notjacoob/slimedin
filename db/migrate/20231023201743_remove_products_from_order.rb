class RemoveProductsFromOrder < ActiveRecord::Migration[7.0]
  def change
    remove_column :orders, :products
  end
end
