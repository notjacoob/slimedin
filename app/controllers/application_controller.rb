class ApplicationController < ActionController::Base

  before_action :authenticate_user!, except: [:index]

  def index
  end
  def products
  end

  def orders
  end

  def order_success
    @order = Order.find(params[:pid])
  end

end
