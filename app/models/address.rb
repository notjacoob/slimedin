class Address < ApplicationRecord
  encrypts :line1, :zip
  belongs_to :user
  has_many :orders
  enum address_type: {
    billing: 0,
    shipping: 1
  }
  def address_select
    "#{line1}, #{city}, #{state} #{zip} (#{last_name}, #{first_name})"
  end
end
