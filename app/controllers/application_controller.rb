class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def get_yomi(word)
    node = MeCab::Tagger.new.parseToNode(word)
  	node = node.next
  	elem = node.feature.split(",")
  	elem[7] = node.surface if !elem[7]
  	elem[7]
  end
end
