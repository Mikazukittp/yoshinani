Rails.application.routes.draw do
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
      end
      resources :groups do
        resources :users, controller: 'group_users', only: %i(index create destroy) do
          collection do
            patch :accept
          end
        end
      end
      resources :payments
      resource :passwords, only: %i(update)
      resources :oauths, only: %i(create)
    end
  end
end
