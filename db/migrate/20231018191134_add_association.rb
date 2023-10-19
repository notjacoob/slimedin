class AddAssociation < ActiveRecord::Migration[7.0]
  def change
    change_table :orders do |t|
      t.belongs_to :products
      t.belongs_to :users
    end
  end
end
