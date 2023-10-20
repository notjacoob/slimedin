class OrdersController < ActionController::Base
  require 'uri'
  require 'json'
  require 'net/http'
  skip_before_action :verify_authenticity_token # TODO fix this
  before_action :paypal_init


  def create_order
    params.permit(:cartId)
    if params[:pid] != ""
      @cart = Cart.where(id: params[:cartId]).first!
      @billing_address=Address.where(user: current_user, address_type: :billing).order("created_at").last
      @shipping_address=Address.where(user: current_user, address_type: :shipping).order("created_at").last
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
        order = Order.new(products: @cart.products, user: current_user)
        order.price_cents = price
        order.shipping_address = @shipping_address
        order.billing_address = @billing_address
        order.token = response.result.id
        if order.save! # I spent 30 minutes on this because I named the column plural instead of singular oh my god
          @cart.products = []
          @cart.save!
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

      if order.save
        body = gen_discord_body(order)
        res = Net::HTTP.post(URI.parse(discord_webhook), body, {"Content-Type": "application/json"})
        return render :json => {:status => response.result.status, :order => order.id}, :status => :ok
      end
    rescue PayPalHttp::HttpError => ioe
      # TODO handle error
    end
  end

  def add_cart
    if current_user.cart != nil
      @cart = current_user.cart
      @cart.update_attribute :products, @cart.products.push(params[:pid])
      @cart.save
      redirect_to controller: :application, action: :productsv2
    else
      @cart = Cart.new
      @cart.user = current_user
      @cart.update products: [params[:pid]]
      @cart.save
    end
  end
  def remove_cart
    @cart = current_user.cart
    @cart.update_attribute :products, remove_first(@cart.products, params[:pid])
    @cart.save
    redirect_to controller: :application, action: :cart
  end
  def payment_proceed
    @billing_address = Address.new
    @billing_address.line1 = params[:billing_address][:line1]
    @billing_address.city = params[:billing_address][:city]
    @billing_address.state = params[:billing_address][:state_province]
    @billing_address.zip = params[:billing_address][:zip]
    @billing_address.save_for_later = params[:billing_address][:save]
    @billing_address.address_type = :billing
    @billing_address.user = current_user

    @shipping_address = Address.new
    @shipping_address.line1 = params[:shipping_address][:line1]
    @shipping_address.city = params[:shipping_address][:city]
    @shipping_address.state = params[:shipping_address][:state_province]
    @shipping_address.zip = params[:shipping_address][:zip]
    @shipping_address.save_for_later = params[:shipping_address][:save]
    @shipping_address.address_type = :shipping
    @shipping_address.user = current_user

    @shipping_address.save!
    @billing_address.save!
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
  def discord_webhook
    'https://discord.com/api/webhooks/1164792659232165939/J8WWLJih6qSy9USCg4z0l8tyNnrXrBWmFFv2wO7COs_lsGZb85GFjOTRdOOaiUWHWl9I'
  end
  def gen_discord_body(order)
     "{
        \"content\": null,
        \"embeds\": [
            {
                \"title\": \"New Order\",
                \"url\": \"http://localhost:3000/orders\",
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
                        \"value\": \"#{order.products.length}\"
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