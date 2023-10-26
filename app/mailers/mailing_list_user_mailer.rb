class MailingListUserMailer < ApplicationMailer
  def new_order
    @user = params[:user]
    @order = params[:order]
    @admin = params[:admin]
    mail(to: @user.email, subject: "Order created: ##{@order.id}")
  end
  def new_order_client
    @user = params[:user]
    @order = params[:order]
    @admin = false
    mail(to: @user.email, subject: "Order created: ##{@order.id}")
  end
end
