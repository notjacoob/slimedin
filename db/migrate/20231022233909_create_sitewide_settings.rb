class CreateSitewideSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :sitewide_settings , id: false, primary_key: :key do |t|
      t.string :key, null: false, unique: true
      t.text :value, null: false
      t.timestamps
    end
  end
end
