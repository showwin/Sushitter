class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy]

  def create
    Dictionary.make(params[:owner])
    respond_to do |format|
      format.js
    end
  end

  def update
    
  end

  def destroy
    @dictionary.destroy
    respond_to do |format|
      format.html { redirect_to dictionaries_url }
      format.json { head :no_content }
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
