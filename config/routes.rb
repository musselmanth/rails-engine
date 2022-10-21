Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do

      namespace :items do
        get "/find", to: "search#show", as: :find, defaults: {num_results: 1}
        get "/find_all", to: "search#show", as: :find_all, defaults: {num_results: nil}
      end

      namespace :merchants do
        get "/find", to: "search#show", as: :find, defaults: {num_results: 1}
        get "/find_all", to: "search#show", as: :find_all, defaults: {num_results: nil}
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
