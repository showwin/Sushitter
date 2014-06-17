class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  def index
    @tweets = Tweet.all
  end

  def get
    from = params[:from].to_i
    to = from+params[:to].to_i
    @tweets = Tweet.where(:id => from..to)
  end
  
  def create
    @tweet = Tweet.new(tweet_params)

    respond_to do |format|
      format.js if @tweet.save
    end
  end

  def destroy
    @tweet.destroy
    respond_to do |format|
      format.html { redirect_to tweets_url }
      format.json { head :no_content }
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