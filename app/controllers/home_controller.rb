#coding: UTF-8
class HomeController < ApplicationController
  require "mecab"
  
  def index
    @tweet = Tweet.new
    @dic_owners = Dictionary.find_by_sql("select distinct owner from dictionaries")
  end
  
  def test
    @node = MeCab::Tagger.new.parseToNode("3月の給料もらったけど、時給117円から166円に上ってた。うれしーわー！！！！！！！！！！")
  end

  def set_init
  end
  
end
