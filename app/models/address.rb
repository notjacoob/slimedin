class Address < ApplicationRecord
  encrypts :line1, :zip
  belongs_to :user
  belongs_to :address
  has_many :orders
  enum address_type: {
    billing: 0,
    shipping: 1
  }
end
