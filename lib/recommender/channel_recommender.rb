module Recommender
  class ChannelRecommender
    include Predictor::Base

    input_matrix :properties, weight: 1.0
    input_matrix :performance, weight: 0.0
    input_matrix :channels, weight: 0.0
    input_matrix :scores, weight: 0.0

    def update_label(top_contenders)
      Predictor.redis.smembers("predictor:Recommender:ChannelRecommender:performance:items:high").each do |m|
        self.delete_from_matrix!(:performance, m)
      end
      high = []
      top_contenders.each do |contender|
        high << contender[0]
        self.performance.add_to_set("high", contender[0])
      end
      return high
    end

    def load_properties(properties)
      JSON.parse(properties).each do |p|
        self.add_to_matrix(:properties, p[0], p[1])
        self.add_to_matrix(:channels, "all_channels", p[1])
      end
    end

    def add_to_channel_scores(array)
      array = JSON.parse(array).compact
      array.each do |c|
        path = "predictor:Recommender::ChannelRecommender:scores:items:#{c}"
        if Predictor.redis.exists(path)
          temp = Predictor.redis.smembers(path)[0].to_i
          Predictor.redis.del(path)
          self.add_to_matrix(:scores, c, temp+1)
        else
          self.add_to_matrix(:scores, c, 1)
        end
      end
      self.get_scores
    end

    def remove_from_channel_scores(array)
      array = JSON.parse(array).compact
      array.each do |c|
        path = "predictor:Recommender::ChannelRecommender:scores:items:#{c}"
        if Predictor.redis.exists(path)
          temp = Predictor.redis.smembers(path)[0].to_i
          Predictor.redis.del(path)
          self.add_to_matrix(:scores, c, temp-1)
        end
      end
      self.get_scores
    end

    def count_props
      counts = {}
      Predictor.redis.smembers("predictor:Recommender::ChannelRecommender:channels:items:all_channels").each do |c|
        counts[c.to_i] = self.properties.sets_for(c).length
      end
      return counts
    end

    def get_scores
      scores = {}
      channels = {}
      Predictor.redis.keys("*scores:items:*").each do |path|
        score = Predictor.redis.smembers(path)
        channel = path.split(':').last
        channels["#{channel}"] = score[0]
      end
      channel_props = self.count_props
      channels.each do |c, v|
        score = v.to_f/channel_props[c.to_i].to_f
        if score == Float::INFINITY || score.nan?
          score = 0
        end
        scores[c] = score
      end
      puts 'done!'
      top_contenders = scores.sort { |a, b| b[1]<=>a[1] }.take(3)
      self.update_label(top_contenders)
    end

    def remove_from_properties(array)
      array = JSON.parse(array).compact
      array.each do |c|
        path = "predictor:Recommender::ChannelRecommender:properties:items:#{c}"
        if Predictor.redis.exists(path)
          Predictor.redis.del(path)
        end
      end
      self.get_scores
    end
  end
end