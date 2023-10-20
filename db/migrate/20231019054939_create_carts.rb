class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.belongs_to :user
      t.belongs_to :order
      t.text :products, default: [].to_yaml
      t.timestamps
    end
  end
end
