class ApplicationController < ActionController::Base
  include Rails.application.routes.url_helpers

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_poll
      key = "#{ request.host }/#{ params[:poll] }"
      Rails.cache.delete(key) if Rails.cache.read(key).nil?

      @poll = Rails.cache.fetch key, expires_in: 10.minutes, race_condition_ttl: 20.seconds do
        if params[:poll]
          Poll.with_associations.find_by!(slug: params[:poll])
        else
          Poll.with_associations.joins(:domains).find_by!(domains: {domain: request.host})
        end
      end
    end
end
