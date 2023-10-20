Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  devise_scope :user do
    root to: "application#index"
    get "sign-in", to: "devise/sessions#new"
    get "sign-up", to: "devise/registrations#new"
    post "create-order/:cartId", :to => "orders#create_order"
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
    get "payment", to: "application#payment"
    get "empty-cart", to: "application#empty_cart_error"
  end

  if Rails.env.development?
    get "set-admin/:uid", to: "administrator#set_admin"
  end

end
