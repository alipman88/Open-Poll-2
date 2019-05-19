class Admin::AnswersController < ApplicationController
  http_basic_authenticate_with name: ENV['ADMIN_USER'], password: ENV['ADMIN_PASSWORD']
  layout 'admin'
  before_action :set_poll
  before_action :set_question, only: [:new,:edit, :update, :destroy]
  before_action :set_answer, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @answer = Answer.new
  end

  def edit
  end

  def create
    @answer = Answer.new(answer_params)
    @answer.question_id = params[:question_id]

    respond_to do |format|
      if @answer.save
        format.html { redirect_to admin_poll_answers_path(@poll), notice: 'Answer was successfully created.' }
        format.json { render :show, status: :created, location: @answer }
      else
        format.html { render :new }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html { redirect_to admin_poll_answers_path(@poll), notice: 'Answer was successfully updated.' }
        format.json { render :show, status: :ok, location: @answer }
      else
        format.html { render :edit }
        format.json { render json: @answer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @answer.destroy
    respond_to do |format|
      format.html { redirect_to admin_poll_answers_path(@poll), notice: 'Answer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find(params[:poll_id])
    end

    def set_question
      @question = @poll.questions.find(params[:question_id])
    end

    def set_answer
      @answer = @question.answers.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def answer_params
      params.require(:answer).permit!
    end
end
