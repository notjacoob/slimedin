class CreateMailingListUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :mailing_list_users do |t|
      t.references :mailing_list
      t.text :email
      t.timestamps
    end
  end
end
