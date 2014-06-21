#coding: UTF-8
class HomeController < ApplicationController
  
  def index
    @tweet = Tweet.new
    @dic_owners = Dictionary.owners
  end
  
end
