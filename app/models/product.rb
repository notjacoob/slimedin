class Product < ApplicationRecord
  validates_size_of :thumbnail, maximum: 50.megabytes, message: "Please make the image smaller!"

  has_many :order
  has_many :cart_products
  monetize :price_cents
  has_one_attached :thumbnail

  def product_tagline
    "#{name}, $#{Money.from_cents(price_cents)}"
  end

end
