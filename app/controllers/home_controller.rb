#coding: UTF-8
class HomeController < ApplicationController
  require "mecab"
  
  def index
    @tweet = Tweet.new
    @dic_owners = Dictionary.find_by_sql("select distinct owner from dictionaries")
  end
  
  def test
    @node = MeCab::Tagger.new.parseToNode("今日は暇だしとなりのトトロでも見ようか。ついでにApple Storeにも行く")
    #while node
    #  elem = node.feature.split(",")
    #  parts = elem[0]
    #  origin = elem[6]
    #  node = node.next
    #end
  end

  def set_init
  end
  
end
