Fulcrum::Application.routes.draw do

  get "story/new"
  get "locales" => "application#locales"

  resources :projects do
    resources :users, :only => [:index, :create, :destroy]
    resources :changesets, :only => [:index]
    resources :stories, :only => [:index, :create, :update, :destroy, :show] do
      resources :notes, :only => [:index, :create, :show, :destroy]
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

  devise_for :users, :controllers => { 
      :confirmations => "confirmations", 
      :registrations => "registrations"
    }

  if Rails.env.development?
    get 'testcard' => 'static#testcard'
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of named route:
  #   get 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root "projects#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
