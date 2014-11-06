#encoding: utf-8
module Jobs
  class LoadPagesJob < Struct.new(:pages, :site_id)
    def perform
      page_titles = []

      JSON.parse(pages).each do |page|
          page_titles << page
      end
      puts page_titles
      cr = Recommender::PageRecommender.new
      cr.load_pages(page_titles, site_id)
      cr.process!
    end
  end
end