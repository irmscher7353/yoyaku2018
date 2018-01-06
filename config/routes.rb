Rails.application.routes.draw do
  resources :products
  resources :titles do
		collection do
			get :update_index
		end
  end
  resources :menus
  resources :preferences
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
