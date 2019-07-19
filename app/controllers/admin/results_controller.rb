class Admin::ResultsController < Admin::AdminController
  layout 'application'
  before_action :set_poll
  before_action :admin

  def results
    question_id_1, question_id_2 = nil, nil
    if params[:question_id_1].nil? && params[:question_id_2].nil?
      question_id_1 = @poll.questions.first.id
      question_id_2 = @poll.questions.second.id
    elsif params[:question_id_2].nil?
      question_id_1 = params[:question_id_1]
      question_id_2 = 0
    else
      question_id_1 = params[:question_id_1]
      question_id_2 = params[:question_id_2]
    end

    @question = @poll.questions.select{ |q| q.id == params[:question_id_1].to_i }.first || @poll.questions.first
    @crosstabs = @poll.cached_crosstabs question_id_1, question_id_2, extra_1: params[:extra_1]
    render "results/results"
  end

  private
    def admin
      @admin = true
    end
end