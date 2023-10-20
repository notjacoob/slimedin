class ApplicationController < ActionController::Base

  before_action :authenticate_user!, except: [:index]

  def index
  end

  def productsv2
  end

  def cart
    if current_user.cart == nil
      @cart = Cart.new
      @cart.user = current_user
      @cart.save
    end
  end

  def orders
  end

  def empty_cart_error
  end

  def checkout
    @cart = current_user.cart
    if !@cart or @cart.products.length == 0
      redirect_to action: :empty_cart_error
    end
  end

  def payment
    @cart = current_user.cart
    @billing_address = current_user.addresses.where(address_type: :billing)
    @shipping_address = current_user.addresses.where(address_type: :shipping)
    if !@cart or @cart.products.length == 0 or @billing_address.length == 0 or @shipping_address.length == 0
      redirect_to action: :empty_cart_error
    end
    @billing_address = @billing_address.order("created_at").last
    @shipping_address = @shipping_address.order("created_at").last
    @subtotal = calc_subtotal(@cart.products)
    @tax = calc_tax_rate(@billing_address.state, @billing_address.city, @subtotal)
    @total = calc_total(@subtotal, @tax)
    @cart.total = @total
    @cart.save!
  end

  def order_success
    @order = Order.find(params[:pid])
  end

  private

  def tax_rates
    {AZ_phoenix: 8.6, AZ_glendale: 8.6}
  end
  def calc_subtotal(products)
    subtotal = 0
    products.each do |p|
      subtotal += Product.where(id: p).first!.price_cents
    end
    subtotal
  end
  def calc_tax_rate(state, city, subtotal)
    taxrate = tax_rates["#{state}_#{city.downcase}".to_sym]
    (subtotal / 100.00) * taxrate
  end
  def calc_total(subtotal, tax)
    subtotal + tax
  end

end
