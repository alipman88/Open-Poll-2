class VotesController < ApplicationController
  before_action :set_poll, only: [:new]

  def new

  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:ballot).permit(:email, :name, :zip, :phone)
    end
end
