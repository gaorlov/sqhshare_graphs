SqlshareGraphs::Application.routes.draw do

  resources :graphs do 
    collection do
      get 'index'
      post 'store_api_key'
    end
  end

  resources :sessions do
    get 'new', :on => :collection
    post 'create', :on => :collection
  end

  root :to => 'graphs#index'

end
