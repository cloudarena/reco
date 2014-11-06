module Api
  class PiwikApiController < ApplicationController
    include PiwikApi
    include Recommender
    respond_to :html
    respond_to :json

    def add
      request.body.set_encoding('UTF-8')
      #render text: PiwikApi::PiwikFeeder.new.get_urls
      respond_to do |format|
        format.html do
          ###
        end
        format.json do
          #Delayed::Job.enqueue(Jobs::LoadPagesJob.new(params[:pages], params[:site_id]))
          Jobs::LoadPagesJob.new(params[:pages], params[:site_id]).perform
          render text: "done!"
        end
      end
    end

    def recommend
      pr = Recommender::PageRecommender.new
      render text: pr.predictions_for(params[:id], matrix_label: :sites, with_scores: true)
    end
  end
end