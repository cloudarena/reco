module Jobs
  class AddToChannelScoresJob < Struct.new(:scores)
    def perform
      cr = Recommender::ChannelRecommender.new
      cr.add_to_channel_scores(scores)
    end
  end
end