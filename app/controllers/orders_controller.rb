class OrdersController < ActionController::Base
  require 'uri'
  require 'json'
  require 'net/http'
  skip_before_action :verify_authenticity_token # TODO fix this
  before_action :paypal_init


  def create_order
    @use_billing = SitewideSetting.find_by(key: "use_billing_address")
    if params[:pid] != ""
      @cart = Cart.where(id: params[:cartId]).first!
      if @use_billing.value == "true"
        @billing_address=Address.find(params[:billingId])
      end
      @shipping_address=Address.find(params[:shippingId])
      price = @cart.total
      new_request = PayPalCheckoutSdk::Orders::OrdersCreateRequest::new
      new_request.request_body({
                                 :intent => 'CAPTURE',
                                 :purchase_units => [
                                   {
                                     :amount => {
                                       :currency_code => 'USD',
                                       :value => Money.from_cents(price)
                                     }
                                   }
                                 ]
                               })
      begin
        response = @client.execute new_request
        order = Order.new(user: current_user)
        order.price_cents = price
        order.shipping_address = @shipping_address
        order.status = :submitted
        order.cart = @cart
        if (@use_billing.value = "true")
          order.billing_address = @billing_address
        end
        order.token = response.result.id
        if order.save! # I spent 30 minutes on this because I named the column plural instead of singular oh my god
          return render :json => {:token => response.result.id}, :status => :ok
        else
        end
      rescue PayPalHttp::HttpError => ioe
        # HANDLE THE ERROR
      end
    end

  end
  def capture_order
    request = PayPalCheckoutSdk::Orders::OrdersCaptureRequest::new params[:order_id]

    begin
      response = @client.execute request
      order = Order.find_by :token => params[:order_id]
      order.paid = response.result.status == 'COMPLETED'
      @cart = order.cart
      @cart.order = order
      @cart.completed = true
      @cart.save!
      @new_cart = Cart.new
      @new_cart.user = current_user
      @new_cart.completed = false
      @new_cart.total = 0
      @new_cart.save!
      if order.save
        body = gen_discord_body(order)
        res = Net::HTTP.post(URI.parse(ENV["DISCORD_WEBHOOK"]), body, {"Content-Type": "application/json"})
        return render :json => {:status => response.result.status, :order => order.id}, :status => :ok
      end
    rescue PayPalHttp::HttpError => ioe
      # TODO handle error
    end
  end

  def add_cart
      @cart = current_user.current_cart
      @product = Product.find(params[:pid])
      @existing_product = @cart.cart_products.where(product: @product)
      if @existing_product.length < 1
        @new_product = CartProduct.new
        @new_product.product = @product
        @new_product.quantity = 1
        @new_product.cart = @cart
        @new_product.save!
      else
        @existing_product = @existing_product.first!
        @existing_product.quantity += 1
        @existing_product.save!
      end
      @cart.save!
      redirect_to controller: :application, action: :cart
  end
  def remove_cart
    @cart = current_user.current_cart
    @product = Product.find(params[:pid])
    @cart_product = @cart.cart_products.where(product: @product).first!
    if @cart_product.quantity > 1
      @cart_product.quantity = @cart_product.quantity - 1
      @cart_product.save!
    else
      @cart_product.delete
    end
    redirect_back(fallback_location: :root_path)
  end
  def payment_proceed
    @use_billing = SitewideSetting.find_by(key: "use_billing_address")
    if params[:type] == "new"
      if @use_billing.value == "true"
        @billing_address = Address.new
        @billing_address.line1 = params[:billing_address][:line1]
        @billing_address.city = params[:billing_address][:city]
        @billing_address.state = params[:billing_address][:state_province]
        @billing_address.zip = params[:billing_address][:zip]
        @billing_address.first_name = params[:billing_address][:first_name]
        @billing_address.last_name = params[:billing_address][:last_name]
        @billing_address.address_type = :billing
        @billing_address.user = current_user
        @billing_address.save!
      end

      @shipping_address = Address.new
      @shipping_address.line1 = params[:shipping_address][:line1]
      @shipping_address.city = params[:shipping_address][:city]
      @shipping_address.state = params[:shipping_address][:state_province]
      @shipping_address.zip = params[:shipping_address][:zip]
      @shipping_address.first_name = params[:shipping_address][:first_name]
      @shipping_address.last_name = params[:shipping_address][:last_name]
      @shipping_address.address_type = :shipping
      @shipping_address.user = current_user

      @shipping_address.save!
    else
      if @use_billing.value == "true"
        @billing_address = Address.find(params[:billing_address_id])
      end
      @shipping_address = Address.find(params[:shipping_address_id])
    end
    render({:json => "{\"shipping_id\": #{@shipping_address.id}, \"billing_id\": #{@use_billing.value == "true" ? @billing_address.id : -1}}"})
  end

  def add_cart_qty
    @cart = current_user.current_cart
    @product = Product.find(params[:pid])
    @cart_product = @cart.cart_products.where(product: @product).first!
    @cart_product.quantity = @cart_product.quantity + 1
    @cart_product.save!
    redirect_back(fallback_location: :root_path)
  end
  def remove_cart_qty
    @cart = current_user.current_cart
    @product = Product.find(params[:pid])
    @cart_product = @cart.cart_products.where(product: @product).first!
    if @cart_product.quantity > 1
      @cart_product.quantity = @cart_product.quantity - 1
      @cart_product.save!
    else
      @cart_product.delete
    end
    redirect_back(fallback_location: :root_path)
  end

  private
  def paypal_init
    client_id = ENV["PAYPAL_CLIENT_ID"]
    client_secret = ENV["PAYPAL_CLIENT_SECRET"]
    environment = PayPal::SandboxEnvironment.new client_id, client_secret
    @client = PayPal::PayPalHttpClient.new environment
  end
  def remove_first(array, item)
    newarray = []
    covered = false
    array.each do |s|
      if s != item || covered
        newarray.push(s)
      else
        covered = true
      end
    end
    newarray
  end
  def gen_discord_body(order)
     "{
        \"content\": null,
        \"embeds\": [
            {
                \"title\": \"New Order\",
                \"url\": \"http://localhost:3000/admin-portal/orders#order-table-#{order.id}\",
                \"color\": 5814783,
                \"fields\": [
                    {
                        \"name\": \"Time\",
                        \"value\": \"#{order.created_at.to_s.gsub!(" ", ", ")}\"
                    },
                    {
                        \"name\": \"Total\",
                        \"value\": \"$#{Money.from_cents(order.price_cents)}\"
                    },
                    {
                        \"name\": \"Item Count\",
                        \"value\": \"#{order.cart.cart_products.length}\"
                    },
                    {
                        \"name\": \"Order ID\",
                        \"value\": \"#{order.id}\"
                    },
                    {
                        \"name\": \"Client\",
                        \"value\": \"#{order.user.email}\"
                    }
                ],
                \"footer\": {
                    \"text\": \"click title to view the order in the portal\"
                }
            }
        ],
        \"username\": \"Slimed In Development\",
        \"avatar_url\": \"https://i.pinimg.com/1200x/1e/de/88/1ede8867e8c809b9e1d79b23daf9e840.jpg\",
        \"attachments\": []
    }"
  end

end