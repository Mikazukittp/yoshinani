Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    scope :v1 do
      resources :users, controller: :user do
        collection do
          post 'sign_in'
        end
      end
      resources :groups, controller: :group
      resources :payments, controller: :payment
    end
  end
end
