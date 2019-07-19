class Admin::ResultsController < Admin::AdminController
  layout 'application'
  before_action :set_poll
  before_action :admin

  def results
    @question = @poll.questions.select{ |q| q.id == params[:question_id_1].to_i }.first || @poll.questions.first
    @crosstabs = @poll.cached_crosstabs question_id_1: params[:question_id_1], question_id_2: params[:question_id_2], extra_1: params[:extra_1]
    render "results/results"
  end

  private
    def admin
      @admin = true
    end
end