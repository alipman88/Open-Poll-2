class Admin::QuestionsController < Admin::AdminController
  before_action :set_poll

  def index
    @poll.questions.build
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find(params[:poll_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def poll_params
      params.require(:poll).permit!
    end
end
