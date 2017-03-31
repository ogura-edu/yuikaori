class ScrapeController < ApplicationController
  def index
  end
  
  def ameblo
  end

  def instagram
  end

  def twitter
  end
  
  def scrape
    if params[:ameblo]
      ameblo = Scrape::AmebloCrawler.new(params[:article_url])
      ameblo.validate
      ameblo.manually_crawl(params: params)
    elsif params[:instagram]
      insta = Scrape::InstagramCrawler.new(params[:post])
      insta.validate
      insta.manually_crawl(params: params)
    elsif params[:twitter]
    end
    redirect_to scrape_index_path
  end
end
