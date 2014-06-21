Sushitter::Application.routes.draw do

  resources :tweets

  root 'home#index'
  
  get 'test' => 'home#test', as: :test
  post 'create_dictionary' => 'dictionaries#create', as: :create_dictionary
  post 'test' => 'home#my_create', as: :create_my_dictionary
  post 'get_tweets' => 'tweets#get', as: :get_tweets
  
end
