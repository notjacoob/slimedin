class ChangeOrderColumnNames < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :users_id, :user_id
    rename_column :orders, :products_id, :product_id
  end
end
