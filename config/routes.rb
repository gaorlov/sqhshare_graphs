SqlshareGraphs::Application.routes.draw do

  resources :graphs do
    collection do
      get 'error'
    end
  end

  resources :api do
    collection do
      get 'dataset'
    end
  end

  resources :sessions do
    collection do
      get 'new'
      post 'create'
      post 'store_api_key'
    end
  end

  resources :sql_share_api_interfaces, :path => 'sql_share' do
    collection do
      get 'dataset_list'
      get 'data_from_sql'
      get 'get_process_data'
      get 'dataset'
    end
  end

  resources :bags, :except => [:show] do
    get 'whoami', on: :collection;
    get 'list', on: :collection;
    post 'add_to_bag', on: :collection;
  end

  get '/bags/:user_id/:id', to: 'bags#show'

  root :to => 'graphs#index'

end
