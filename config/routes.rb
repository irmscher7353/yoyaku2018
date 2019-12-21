Rails.application.routes.draw do
  # root to: 'orders#index' だと url が変わらない．
  root to: redirect('orders')
  resources :names do
    collection do
      get :stats
      get :update_name_list
      get :update_phone_list
    end
    member do
      patch :inline_update
    end
  end
  resources :line_items
  resources :orders do
    collection do
      get :edit_order
      get :names
      get :show_order
      get :summary
      get :undeliver
    end
  end
  resources :buyers
  resources :customers
  resources :products
  resources :titles do
    collection do
      get :update_index
    end
  end
  resources :menus do
    collection do
      get :set_current
    end
  end
  resources :preferences
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
