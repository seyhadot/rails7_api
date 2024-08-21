Rails.application.routes.draw do
  # devise_for :users, controllers: {
  #   sessions: 'users/sessions',
  #   registrations: 'users/registrations',
  #   passwords: 'users/passwords'
  # },


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

  namespace :api do
    namespace :v1 do
      get 'current', to: 'users#current'
    end
  end
end