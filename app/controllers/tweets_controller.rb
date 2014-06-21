class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  def get
    from = params[:from].to_i
    to = params[:to].to_i
    @tweets = Tweet.where(:id => from..to)
  end
  
  def create
    @tweet = Tweet.new(tweet_params)
    if tweet_params[:emotion] == "auto"
      self_emo = false
      @tweet.score = @tweet.get_score
      @tweet.emotion = @tweet.get_emotion
    else
      self_emo = true
      @tweet.score = @tweet.emotion.to_i
    end
    Dictionary.value_update(@tweet, self_emo)

    respond_to do |format|
      format.js if @tweet.save
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tweet_params
      params.require(:tweet).permit(:name, :emotion, :content)
    end
end
