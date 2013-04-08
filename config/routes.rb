Eveyl::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "users/registrations", :passwords => "users/passwords"}

  resources :home, only: [:index]

  resource :user, only: [:show] do
    resources :api_keys, only: [:show, :new, :create, :destroy]

    resource :user_profile, only: [:show, :update]
  end

  resources :orders, only: [:show, :index] do
    collection do
      get :recent
      post :search
    end
  end

  resources :accounts, only: [:show, :index] do
    resources :characters, only: [:show, :index]
  end

  resources :character_assets, only: [:index] do
    collection do
      post :search
    end
  end

  resources :characters, only: [:show, :index] do
    resources :character_assets, only: [:index] do
      collection do
        post :search
      end
    end
  end

  resources :corporations, only: [:index, :show]

  resources :types, only: [:index, :show]

  resources :regions, only: [:index, :show] do
    resources :solar_systems, only: [:index, :show] do
      resources :stations, only: [:index]
    end
  end

  resources :market_groups, only: [:index, :show]

  resources :blueprints

  resources :api_logs, only: [:index]

  resource :status, only: [:show]

  resource :links, only: [:show]

  namespace :api, defaults: {format: 'json'}, only: [:index, :show, :create, :update, :destroy] do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      root :to => 'root#index'

      resources :regions, only: [:index, :show] do
        resources :solar_systems, only: [:index, :show]

        collection do
          get :names
        end
      end

      resources :solar_systems, only: [:index, :show] do
        collection do
          get :names
        end
      end

      resources :types, only: [:index, :show] do
        resource :order_histories, only: [:show]
        resources :orders, only: [:index]
        collection do
          get :names
        end
      end

      resources :orders, only: [:index, :show] do
        collection do
          get :search
        end
      end

      resources :order_histories, only: [:search] do
        collection do
          get :search
        end
      end

      resources :order_stats, only: [:search] do
        collection do
          get :search
        end
      end

      match "*path", :to => "api#not_found"
    end
  end

  root :to => "home#index"
end
