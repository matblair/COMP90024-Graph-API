Rails.application.routes.draw do

  # Info pages
  get 'info/index'
  get 'info/users'
  get 'info/tweets'
  get 'info/topics'

  # API Pages
  namespace :api do 
    get 'tweets/index' => '/api/tweets#index'
    post 'tweets/submit' => '/api/tweets#submit'
  end

  # Root page
  root 'info#index'

end
