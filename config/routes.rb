Rails.application.routes.draw do
  get 'story/new'
  get 'locales' => 'application#locales'

  resources :projects do
    resources :users, only: [:index, :create, :destroy]
    resources :changesets, only: [:index]
    resources :stories, only: [:index, :create, :update, :destroy, :show] do
      resources :notes, only: [:index, :create, :show, :destroy]
      collection do
        get :done
        get :in_progress
        get :backlog
        get :import
        post :import_upload
      end
      member do
        put :start
        put :finish
        put :deliver
        put :accept
        put :reject
      end
    end
  end

  devise_for :users, controllers: {
    confirmations: 'confirmations',
    registrations: 'registrations'
  }

  if Rails.env.development?
    get 'testcard' => 'static#testcard'
  end

  root 'projects#index'

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
end
