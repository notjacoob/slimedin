class Order < ApplicationRecord
  belongs_to :user
  monetize :price_cents
  serialize :products, Array
  belongs_to :shipping_address, :class_name => "Address", foreign_key: "shipping_address_id"
  belongs_to :billing_address, :class_name => "Address", foreign_key: "billing_address_id", optional: true
end
