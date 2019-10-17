class Admin::ResultsController < Admin::AdminController
  layout 'application'
  before_action :set_poll
  before_action :admin
  protect_from_forgery except: :crosstabs

  def results
    @question = @poll.questions.select{ |q| q.id == params[:question_id_1].to_i }.first || @poll.questions.first
    render "results/results"
  end

  def crosstabs
    question_id_1, question_id_2 = nil, nil

    if params[:question_id_1].nil?
      question_id_1 = @poll.questions.first.try(:id).to_i
      question_id_2 = @poll.questions.second.try(:id).to_i
    elsif params[:question_id_2].nil?
      question_id_1 = params[:question_id_1].to_i
      question_id_2 = 0
    else
      question_id_1 = params[:question_id_1].to_i
      question_id_2 = params[:question_id_2].to_i
    end

    render js: @poll.cached_crosstabs(question_id_1, question_id_2, extra_1: params[:extra_1])
  end

  private
    def admin
      @admin = true
    end
end