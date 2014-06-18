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
    self_emo = false
    if tweet_params[:emotion] == "auto"
      #感情の判別
      node = MeCab::Tagger.new.parseToNode(@tweet.content)
      score = 0.0
      node = node.next
      while node.next
        elem = (node.feature).split(",")
        parts = elem[0]
        if parts == "名詞" || parts == "動詞" || parts == "形容詞" || parts == "副詞" || parts == "助動詞"
          elem[6] = node.surface if elem[6]=="*"
          origin = MeCab::Tagger.new.parseToNode(elem[6])
        	origin = origin.next
        	oelem = origin.feature.split(",")
        	oelem[7] = origin.surface if !oelem[7]
        	elem[7] = oelem[7]
          word = elem[6]
          kana = elem[7].tr("ァ-ン", "ぁ-ん")
          result = Dictionary.where(word: word, kana: kana).first
          if result
            score += result.value
          end
        end
        node = node.next
      end
      score>=0 ? @tweet.emotion = 1 : @tweet.emotion = -1
      @tweet.score = score
    else
      self_emo = true
      @tweet.score = @tweet.emotion.to_i
    end
    
    #辞書の修正
    score = @tweet.score
    node = MeCab::Tagger.new.parseToNode(@tweet.content)
    node = node.next
    while node.next
      elem = (node.feature).split(",")
      parts = elem[0]
      if parts == "名詞" || parts == "動詞" || parts == "形容詞" || parts == "副詞" || parts == "助動詞"
        elem[6] = node.surface if elem[6]=="*"
        origin = MeCab::Tagger.new.parseToNode(elem[6])
      	origin = origin.next
      	oelem = origin.feature.split(",")
      	oelem[7] = origin.surface if !oelem[7]
      	elem[7] = oelem[7]
        word = elem[6]
        kana = elem[7].tr("ァ-ン", "ぁ-ん") if elem[7]
        result = Dictionary.where(word: word, kana: kana).first
        if result
          if self_emo
            (result.value + score/500.0) > 1 ? result.value = 1 : result.value += score/500.0  
          else
            (result.value + score/1000.0) > 1 ? result.value = 1 : result.value += score/1000.0
          end
          result.save
        else
          dic = Dictionary.new
          dic.owner = @tweet.name
          dic.word = word
          dic.kana = kana
          dic.value = 0
          dic.save
        end
      end
      node = node.next
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
