class AddListedToProducts2 < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :listed
    add_column :products, :listed, :boolean, default: true
  end
end
