module Jobs
  class RemoveFromChannelScoresJob < Struct.new(:scores)
    def perform
      cr = Recommender::ChannelRecommender.new
      cr.remove_from_channel_scores(scores)
    end
  end
end