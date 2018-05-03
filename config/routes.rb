require 'resque/server'
Rails.application.routes.draw do

  root to: 'stocks#show'
  get 'stocks' => 'stocks#show'
  get 'stocks/show'
  get 'stocks/import'
  post 'stocks/import'
  get 'stocks/list'
  post 'stocks/list'
  get 'stocks/setup'
  post 'stocks/setup'
  get 'stocks/check'
  post 'stocks/check'
  get 'stocks/upload'
  post 'stocks/upload'
  get 'home/show'


  mount Resque::Server.new, at: "/resque"

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/sign_in' => 'devise/sessions#new'
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => {
   :registrations => 'users/registrations'
  }
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
