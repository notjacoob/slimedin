class AdministratorController < ApplicationController
  before_action :authenticate_user!, :user_admin?, except: [:set_admin]
  skip_before_action :verify_authenticity_token
  def add_products_post
    @product = Product.new
    @product.name = params[:name]
    @product.description = params[:description]
    @product.thumbnail.attach params[:thumbnail]
    @product.price_cents = params[:price_cents]
    @product.save!
    redirect_to(controller: :administrator, action: :add_products)
  end

  def delete_mailing_list
    @list = MailingList.find(params[:list])
    @list.delete
    redirect_to(action: :mailing_lists)
  end

  def add_products
  end

  def mailing_lists
  end
  def new_mailing_list
    @name = params[:name]
    @ml = MailingList.new
    @ml.name = @name
    @ml.save
    redirect_to(action: :mailing_lists)
  end

  def add_user_mailing_post
    @mu = MailingListUser.new
    @mu.mailing_list = MailingList.find(params[:mailing_list_id])
    @mu.email = params[:email]
    @mu.save!
    redirect_to(action: :mailing_lists)
  end

  def remove_user_mailing_list
    @mu = MailingListUser.find(params[:user])
    @mu.delete
    redirect_back(fallback_location: :root_path)
  end

  def add_products_update
    @product = Product.find(params[:id])
    @product.name = params[:name]
    @product.description = params[:description]
    if params[:thumbnail]
      @product.thumbnail.attach params[:thumbnail]
    end
    @product.price_cents = params[:price_cents]
    @product.save!
    redirect_to(controller: :administrator, action: :add_products)
  end

  def change_product_listing
    @product = Product.find(params[:id])
    @product.listed = !@product.listed
    @product.save!
    redirect_back(fallback_location: root_url)
  end

  def new_setting
    @setting = SitewideSetting.new
    @setting.key = params[:key]
    @setting.value = params[:value]
    @setting.save!
  end

  def delete_setting
    @setting = SitewideSetting.find_by(key: params[:key])
    @setting.delete
  end

  def admin_portal
  end

  def orders
  end

  def sitewide_settings
  end

  def update_setting
    @setting = SitewideSetting.find(params[:key])
    @setting.value = params[:value]
    @setting.save!
  end

  def update_order_status
    @order = Order.find(params[:orderId])
    @order.status = params[:status].to_i
    @order.save!
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
