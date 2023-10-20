class AddAddressToOrder < ActiveRecord::Migration[7.0]
  def change
    add_reference :addresses, :order
  end
end
