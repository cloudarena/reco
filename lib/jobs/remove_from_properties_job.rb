module Jobs
  class RemoveFromPropertiesJob < Struct.new(:properties)
    def perform
      cr = Recommender::ChannelRecommender.new
      cr.remove_from_properties(properties)
    end
  end
end