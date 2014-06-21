class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token ,:only=>[:create]

  def create
    Dictionary.make(params[:owner], params[:csv_file])
    redirect_to create_teacher_path(params[:owner])
  end

  def start_learning
    emotions=[]
    0.upto(49) do |i|
      emotions[i] = (params["emotion"+i.to_s]).to_i
    end
    Dictionary.start_learning(params[:owner], emotions)
  
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
