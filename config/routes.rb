Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/rails_admin', as: 'rails_admin'
  devise_for :admin_users

  namespace :api, defaults: { format: :json } do
    scope :v1 do
      resources :users do
        collection do
          post :sign_in
          get  :search
        end

        member do
          delete :sign_out
        end

        resource :icon_imgs, only: %i(create update destroy)
      end
      resources :groups do
        resources :users, controller: 'group_users', only: %i(index create destroy) do
          collection do
            patch :accept
          end
        end
      end
      resources :payments
      resource :passwords, only: %i(create update) do
        collection do
          post :init
          patch :reset
        end
      end
      resources :oauth_registrations, only: %i(index create) do
        collection do
          post :add
          delete :destroy
        end
      end
      resource :notification_tokens, only: %i(create update destroy)
    end
  end

  get '*path', controller: 'application', action: 'render_404'
end
