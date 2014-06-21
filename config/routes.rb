Sushitter::Application.routes.draw do

  resources :tweets

  root 'home#index'
  
  get 'test' => 'home#test', as: :test
  post 'create_dictionary' => 'dictionaries#create', as: :create_dictionary
  post 'test' => 'home#my_create', as: :create_my_dictionary
  get 'create_teacher/:owner' => 'home#create_teacher', as: :create_teacher
  post 'start_learning/:owner' => 'dictionaries#start_learning', as: :start_learning
  post 'get_tweets' => 'tweets#get', as: :get_tweets
  
end
