class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :order
  has_many :cart
  has_many :addresses
  after_create :welcome_email

  def current_cart
    cart = Cart.where(user: self, completed: false)
    if cart.length > 0
      cart.order("created_at DESC").last!
    else
      new_cart = Cart.new
      new_cart.user = self
      new_cart.completed = false
      new_cart.total = 0
      new_cart.save!
      new_cart
    end
  end
  def welcome_email
    UserMailer.with(user: self).welcome_email.deliver_later
  end
end
