class AnswersController < ApplicationController
  before_action :set_poll, :set_answer

  def show
  end

  private
    def set_answer
      @answer = Answer.find(params[:answer_id])
    end
end