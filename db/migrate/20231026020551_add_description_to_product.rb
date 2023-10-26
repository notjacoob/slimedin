class AddDescriptionToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :description, :text, default: "No description!"
  end
end
