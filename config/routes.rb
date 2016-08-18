require 'sidekiq/web'
Rails.application.routes.draw do
  mount Attachinary::Engine => "/attachinary"

  get 'story/new'
  get 'locales' => 'application#locales'
  get 'projects/archived' => 'projects#archived'

  resources :projects do
    member do
      get :import
      patch :import_upload
      get :search
    end
    resources :users, only: [:index, :create, :destroy]
    resources :integrations, only: [:index, :create, :destroy]
    resources :changesets, only: [:index]
    resources :stories, only: [:index, :create, :update, :destroy, :show] do
      resources :notes, only: [:index, :create, :show, :destroy]
      resources :tasks, only: [:create, :destroy, :update]
      collection do
        get :done
        get :in_progress
        get :backlog
      end
    end
  end

  namespace :admin do
    resources :users
  end

  devise_for :users, controllers: {
    confirmations: 'confirmations',
    registrations: 'registrations'
  }

  if Rails.env.development?
    get 'testcard' => 'static#testcard'
  end

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'projects#index'

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
end
