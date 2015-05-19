Rails.application.routes.draw do

  # Info pages
  get 'info/index'
  get 'info/users'
  get 'info/tweets'
  get 'info/topics'

  # API Pages
  namespace :api do 
    # Namespace information for access
    get 'tweets/index' => '/api/tweets#index'
    post 'tweets/submit' => '/api/tweets#submit'

    # Actions to get information about topics
    get 'topics/:id'         => '/api/topics#show'
    get 'topics/:id/similar' => '/api/topics#similar'
    get 'topics/:id/users'   => '/api/topics#users'
    get 'topics/:id/path'    => '/api/topics#path'

    # Actions to get information about users
    get 'users/shortest_path' => '/api/users#shortest_path'
  end

  # Root page
  root 'info#index'

end
