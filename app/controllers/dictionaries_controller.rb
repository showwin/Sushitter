class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy]

  def create
    @dictionary = Dictionary.new(dictionary_params)

    respond_to do |format|
      if @dictionary.save
        format.html { redirect_to @dictionary, notice: 'Dictionary was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dictionary }
      else
        format.html { render action: 'new' }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
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
