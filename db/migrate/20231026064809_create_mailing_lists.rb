class CreateMailingLists < ActiveRecord::Migration[7.0]
  def change
    create_table :mailing_lists do |t|
      t.text :name
      t.timestamps
    end
  end
end
