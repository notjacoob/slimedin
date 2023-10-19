class Product < ApplicationRecord
  has_many :order
  monetize :price_cents

  def product_tagline
    "#{name}, $#{Money.from_cents(price_cents)}"
  end

end
