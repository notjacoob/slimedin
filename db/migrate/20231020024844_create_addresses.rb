class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.text :line1
      t.text :city
      t.text :state
      t.integer :zip
      t.boolean :save_for_later
      t.integer :type
      t.belongs_to :user
      t.timestamps
    end
  end
end
