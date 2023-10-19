class AdministratorController < ApplicationController
  before_action :authenticate_user!, :user_admin?, except: [:set_admin]

  def add_products_get
  end
  def add_products_post
    params.permit(:name).permit(:price_cents)
    @product = Product.new
    @product.name = params[:name]
    @product.price_cents = params[:price_cents]
    @product.price_currency = "USD"
    if @product.save
      render html: "<h1>Success! Product created.</h1>".html_safe
    else
      render html: "<h1>There was a problem creating the product!</h1>".html_safe
    end
  end
  def set_admin
    @user = User.find(params[:uid])
    @user.administrator = !@user.administrator
    @user.save!
    render html: "<h1>Success! Admin status: #{@user.administrator}</h1>".html_safe
  end

  private
  def user_admin?
    current_user.administrator
  end
end
