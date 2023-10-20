class ChangeOrdersStructure < ActiveRecord::Migration[7.0]
  def change
    remove_column :orders, :product
    add_column :orders, :products, :text, default: [].to_yaml
  end
end
