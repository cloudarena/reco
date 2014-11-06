module Jobs
  class LoadPropertiesJob < Struct.new(:properties)
    def perform
      cr = Recommender::ChannelRecommender.new
      cr.load_properties(properties)
      cr.process!
    end
  end
end