module Recommender
  class PageRecommender
    include Predictor::Base

    input_matrix :sites, weight: 1.0
    # input_matrix :performance, weight: 0.0
    # input_matrix :channels, weight: 0.0
    # input_matrix :scores, weight: 0.0

    def load_pages(pages, site_id)

      pages.each do |p|
        self.add_to_matrix(:sites, site_id, p)
      end
      process!
    end
  end
end