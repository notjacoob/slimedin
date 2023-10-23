class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :order
  has_many :cart
  has_many :addresses

  def current_cart
    cart.where(completed: false).order("created_at DESC").last!
  end
end
