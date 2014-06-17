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
    if tweet_params[:emotion] == "auto"
      node = MeCab::Tagger.new.parseToNode(@tweet.content)
      score = 0
      node = node.next
      while node.next
        elem = (node.feature).split(",")
        parts = elem[0]
        if parts == "名詞" || parts == "動詞" || parts == "形容詞" || parts == "副詞" || parts == "助動詞"
          word = elem[6]
          kana = elem[7].tr("ァ-ン", "ぁ-ん") if elem[7]
          result = Dictionary.where(word: word, kana: kana).first
          if result
            score += result[:value].to_f
          end
        end
        node = node.next
      end
      score>=0 ? @tweet.emotion = 1 : @tweet.emotion = -1
      @tweet.score = score
    else
      @tweet.score = @tweet.emotion.to_i
    end

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
