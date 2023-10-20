class AddTotalToCart < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :total, :integer, :default => 000
  end
end
