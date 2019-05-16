class BallotsController < ApplicationController
  before_action :set_poll, only: [:new]

  def new

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find_by!(slug: params[:poll])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:ballot).permit(:email, :name, :zip, :phone)
    end
end
