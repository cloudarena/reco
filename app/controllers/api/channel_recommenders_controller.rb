module Api
  class ChannelRecommendersController < ApplicationController
    include Recommender
    include Jobs
    respond_to :html
    respond_to :json

    def property_add
      respond_to do |format|
        format.html do
          ###
        end
        format.json do
          Delayed::Job.enqueue(Jobs::LoadPropertiesJob.new(params[:properties]))
          render text: "done!"
        end
      end
    end

    def property_remove
      respond_to do |format|
        format.html do
          ###
        end
        format.json do
          Delayed::Job.enqueue(Jobs::RemoveFromPropertiesJob.new(params[:properties]))
          render text: "done!"
        end
      end
    end

    def channel_add
      respond_to do |format|
        format.html { render text: current_user }
        format.json do
          #Jobs::AddToChannelScoresJob.new(params[:scores]).perform
          Delayed::Job.enqueue(Jobs::AddToChannelScoresJob.new(params[:scores]))
          render text: "done!"
        end
      end
    end

    def channel_remove
      respond_to do |format|
        format.html { render text: current_user }
        format.json do
          Jobs::RemoveFromChannelScoresJob.new(params[:scores]).perform
          #Delayed::Job.enqueue(Jobs::RemoveFromChannelScoresJob.new(params[:scores]))
          render text: "done!"
        end
      end
    end

    def show
      respond_to do |format|
        format.html { render text: "dasdads" }
        format.json { render text: current_user.email + "  - " + current_user.authentication_token }
      end
    end

    def similar
      respond_to do |format|
        format.html { render text: current_user }
        format.json do
          cr = Recommender::ChannelRecommender.new
          render text: cr.similarities_for(params[:id], with_scores: true)
        end
      end
    end

    def recommend
      respond_to do |format|
        format.html { render text: "We are currently supporting JSON" }
        format.json do
          cr = Recommender::ChannelRecommender.new
          if params[:property_id]
            render text: cr.predictions_for(params[:property_id], matrix_label: :properties, with_scores: true, boost: {performance: {values: ['high'], weight: 2.0}}, limit: 5)
          else
            if params[:channel_set]
              set = JSON.parse(params[:channel_set])
              render text: cr.predictions_for(item_set: set, with_scores: true, boost: {performance: {values: ['high'], weight: 2.0}}, limit: 5)
            else
              render text: "Missing Parameter!"
            end
          end
        end
      end
    end
  end
end