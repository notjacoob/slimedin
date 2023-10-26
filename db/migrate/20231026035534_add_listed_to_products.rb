class AddListedToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :listed, :boolean
  end
end
