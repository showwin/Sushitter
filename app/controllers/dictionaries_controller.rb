class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token ,:only=>[:create]

  def create
    Dictionary.make(params[:owner], params[:csv_file])
    redirect_to new_teacher_path(params[:owner])
  end
  
  def new_teacher
    @tweets = []
    tweets_text=""
    File.open("public/supervised_set/"+params[:owner]+".txt", 'r') { |f| tweets_text=f.read }
    tweets_text.each_line do |line|
      @tweets.push(line)
    end
  end
  
  def start_learning
    emotions=[]
    0.upto(49) do |i|
      emotion = params[:answer]
      num = "answer"+i.to_s
      emotions.push((emotion[num]).to_i)
    end
    Dictionary.supervised_learning(params[:owner], emotions)
    
    respond_to do |format|
      format.js
    end
  end

  private
    def set_dictionary
      @dictionary = Dictionary.find(params[:id])
    end

    def dictionary_params
      params.require(:dictionary).permit(:owner, :word, :value)
    end
end
