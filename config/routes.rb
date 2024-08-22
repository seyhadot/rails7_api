Rails.application.routes.draw do

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  },
  defaults: { format: :json }

  devise_scope :user do
    put 'users/change_password', to: 'users/passwords#change_password'
  end

  namespace :api do
    namespace :v1 do
      get 'current', to: 'users#current'
    end
  end
end