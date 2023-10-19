class OrdersController < ActionController::Base
  skip_before_action :verify_authenticity_token # TODO fix this
  before_action :paypal_init


  def create_order
    params.permit(:pid)
    if params[:pid] != ""
      @product = Product.find(params[:pid])
      price = @product.price_cents
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
        order = Order.new(product: Product.find(params[:pid]), user: current_user)
        order.price_cents = price
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

      if order.save
        return render :json => {:status => response.result.status, :order => order.id}, :status => :ok
      end
    rescue PayPalHttp::HttpError => ioe
      # TODO handle error
    end
  end

  private
  def paypal_init
    client_id = ENV["PAYPAL_CLIENT_ID"]
    client_secret = ENV["PAYPAL_CLIENT_SECRET"]
    environment = PayPal::SandboxEnvironment.new client_id, client_secret
    @client = PayPal::PayPalHttpClient.new environment
  end


end