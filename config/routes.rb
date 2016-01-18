Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    scope :v1 do
      resources :users do
        collection do
          post 'sign_in'
        end
      end
      resources :groups do
        resources :users, controller: 'group_users', only: %i(index create)
      end
      resources :payments
    end
  end
end
