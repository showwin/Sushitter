class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token ,:only=>[:create]

  def create
    Dictionary.make(params[:owner], params[:csv_file])
    redirect_to create_teacher_path(params[:owner])
  end

  def destroy
    @dictionary.destroy
    respond_to do |format|
      format.html { redirect_to dictionaries_url }
      format.json { head :no_content }
    end
  end
  
  def start_learning
    tweets = []
    tweets_text = ""
    File.open("public/teacher/"+params[:owner]+".txt", 'r') { |f| tweets_text=f.read }
    tweets_text.each_line do |line|
      tweets.push(line.chomp)
    end
    0.upto(49) do |i|
      answer = "answer"+i.to_s
      emotion = params[answer]
      tweet = Tweet.new(content: tweets[i], name: params[:owner], emotion: emotion[answer].to_i)
      self_emo = true
      tweet.score = tweet.emotion.to_i
      tweet.save
      Dictionary.value_update(tweet, true)
    end
    Dictionary.no_teacher_learning(params[:owner])
    redirect_to root_path
  end

  private
    def set_dictionary
      @dictionary = Dictionary.find(params[:id])
    end

    def dictionary_params
      params.require(:dictionary).permit(:owner, :word, :value)
    end
end
