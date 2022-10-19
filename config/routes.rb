Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do

      namespace :items do
        resource :find, only: [:show]
        resource :find_all, only: [:show]
      end

      namespace :merchants do
        resource :find, only: [:show]
        resource :find_all, only: [:show]
      end

      resources :merchants, only: [:index, :show] do
        scope module: :merchants do
          resources :items, only: [:index]
        end
      end

      resources :items do
        scope module: :items do
          resource :merchant, only: [:show]
        end
      end

    end
  end
end
