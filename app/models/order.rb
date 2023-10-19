class Order < ApplicationRecord
  belongs_to :product
  belongs_to :user
  monetize :price_cents
end
