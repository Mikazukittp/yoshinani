Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    scope :v1 do
      resources :users do
        collection do
          post 'sign_in'
        end
      end
      resources :groups
      resources :payments
    end
  end
end
