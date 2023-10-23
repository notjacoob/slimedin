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
    get "products", to: "application#productsv2"
    post "add-cart/:pid", to: "orders#add_cart"
    get "cart", to: "application#cart"
    post "remove-cart/:pid", to: "orders#remove_cart"
    get "checkout", to: "application#checkout"
    post "payment-proceed", to: "orders#payment_proceed"
    get "payment/:shippingId", to: "application#payment"
    get "admin-portal/orders", to: "administrator#orders"
    post "admin-portal/update-order-status", to: "administrator#update_order_status"
    get "payment/:shippingId/:billingId", to: "application#payment"
    get "empty-cart", to: "application#empty_cart_error"
    get "admin-portal", to: "administrator#admin_portal"
    get "admin-portal/global-settings", to: "administrator#sitewide_settings"
    post "admin-portal/update-setting", to: "administrator#update_setting"
    post "admin-portal/new-setting", to: "administrator#new_setting"
    delete "admin-portal/delete-setting", to: "administrator#delete_setting"
  end

  if Rails.env.development?
    get "set-admin/:uid", to: "administrator#set_admin"
  end

end
