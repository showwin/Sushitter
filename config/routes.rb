Sushitter::Application.routes.draw do

  resources :tweets

  root 'home#index'
  
  get 'new_teacher/:owner' => 'dictionaries#new_teacher', as: :new_teacher
  post 'create_dictionary' => 'dictionaries#create', as: :create_dictionary
  post 'start_learning/:owner' => 'dictionaries#start_learning', as: :start_learning
  post 'get_tweets' => 'tweets#get', as: :get_tweets
  
end
