class ProductRecommender
	include Predictor::Base
	Predictor.redis = Redis.new(:url => ENV["PREDICTOR_REDIS"], :driver => :hiredis)

	input_matrix :receipts, weight: 1.0
end