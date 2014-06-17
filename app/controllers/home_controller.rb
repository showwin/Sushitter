#coding: UTF-8
class HomeController < ApplicationController
  require "mecab"
  
  def index
    @tweet = Tweet.new
  end
  
  def test
    node = MeCab::Tagger.new.parseToNode("今日はかなり疲れた。明日は何しようかな")
    while node
      elem = node.feature.split(",")
      parts = elem[0]
      origin = elem[6]
      node = node.next
    end
  end
  
  def test_tweet
    @tweets = "おぎゃー"
    respond_to do |format|
      format.html {redirect_to root_path}
      format.js
      format.json {render :json => @tweet}
    end
  end
  
  def set_init
  end
  
end
