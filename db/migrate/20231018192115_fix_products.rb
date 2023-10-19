class FixProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :CreateProducts
    add_column :products, :name, :text
  end
end
