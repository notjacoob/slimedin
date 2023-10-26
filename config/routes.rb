Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  devise_scope :user do
    root to: "application#index"
    get "sign-in", to: "devise/sessions#new"
    get "sign-up", to: "devise/registrations#new"
    post "create-order/:cartId/:shippingId", :to => "orders#create_order"
    post "create-order/:cartId/:shippingId/:billingId", :to => "orders#create_order"
    post "capture-order", :to => "orders#capture_order"
    get "add_products", :to => "administrator#add_products_get"
    post "add_products", :to => "administrator#add_products_post"
    get "orders", to: "application#orders"
    get "order_success/:pid", to: "application#order_success"
    get "products", to: "application#products"
    get "product/:pid", to: "application#product"
    post "add-cart/:pid", to: "orders#add_cart"
    get "cart", to: "application#cart"
    post "remove-cart/:pid", to: "orders#remove_cart"
    get "checkout", to: "application#checkout"
    post "payment-proceed", to: "orders#payment_proceed"
    get "payment/:shippingId", to: "application#payment"
    get "payment/:shippingId/:billingId", to: "application#payment"
    get "empty-cart", to: "application#empty_cart_error"
    post "add-cart-qty/:pid", to: "orders#add_cart_qty"
    post "remove-cart-qty/:pid", to: "orders#remove_cart_qty"
    post "test-email", to: "application#test_email"

    get "admin-portal", to: "administrator#admin_portal"
    scope "admin-portal" do
      get "orders", to: "administrator#orders"
      delete "delete-setting", to: "administrator#delete_setting"
      post "update-setting", to: "administrator#update_setting"
      post "new-setting", to: "administrator#new_setting"
      get "global-settings", to: "administrator#sitewide_settings"
      post "update-order-status", to: "administrator#update_order_status"

      post "add-user-mailing", to: "administrator#add_user_mailing_post"
      get "mailing-lists", to: "administrator#mailing_lists"
      put "mailing-lists", to: "administrator#new_mailing_list"
      post "mailing-lists", to: "administrator#add_user_mailing_post"
      delete "mailing-lists", to: "administrator#remove_user_mailing_list"

      delete "delete-mailing-list", to: "administrator#delete_mailing_list"

      get "add-products", to: "administrator#add_products"
      post "add-products", to: "administrator#add_products_post"
      put "add-products", to: "administrator#add_products_update"
      post "change-product-listing", to: "administrator#change_product_listing"
    end
  end

  if Rails.env.development?
    get "set-admin/:uid", to: "administrator#set_admin"
  end

end
