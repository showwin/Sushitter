Sushitter::Application.routes.draw do

  resources :tweets

  root 'home#index'
  
  get 'test' => 'home#test', as: :test
  post 'set_init' => 'home#set_init', as: :set_init
  post 'get_tweets' => 'tweets#get', as: :get_tweets
  
end
