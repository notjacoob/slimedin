class Order < ApplicationRecord
  belongs_to :user
  monetize :price_cents
  serialize :products, Array
  belongs_to :shipping_address, :class_name => "Address", foreign_key: "shipping_address_id"
  belongs_to :billing_address, :class_name => "Address", foreign_key: "billing_address_id", optional: true
  enum status: {
    submitted: 0,
    accepted: 1,
    rejected: 2,
    shipped: 3,
    completed: 4,
    returned: 5
  }
end
