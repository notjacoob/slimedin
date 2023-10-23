class ModifyCart < ActiveRecord::Migration[7.0]
  def change
    add_column :carts, :completed, :boolean
  end
end
