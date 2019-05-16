class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      @poll = Poll.find_by(slug: params[:poll]) || Domain.find_by!(domain: request.host).poll
    end
end
