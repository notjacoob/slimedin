class RemoveSaveForLaterFromAddresses < ActiveRecord::Migration[7.0]
  def change
    remove_column :addresses, :save_for_later
  end
end
