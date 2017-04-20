class ScrapeController < ApplicationController
  before_action :approved_user!
  before_action :media_exist?, only: :scrape
  
  def scrape
    media = params[:media]
    class_eval <<-EOM
      def #{media}_crawl
        crawler = Scrape::#{media.classify}Crawler.new(#{media}_params)
        if crawler.validate
          crawler.manually_crawl
          redirect_to scrape_index_path
        else
          redirect_back fallback_location: scrape_index_path, alert: crawler.errors
        end
      end
    EOM
    send "#{media}_crawl"
    # case params[:media]
    # when 'ameblo'
    #   ameblo = Scrape::AmebloCrawler.new(ameblo_params)
    #   if ameblo.validate
    #     ameblo.manually_crawl
    #   else
    #     redict_back fallback_location: scrape_index_path, alert: ameblo.errors
    #   end
    # when 'instagram'
    #   insta = Scrape::InstagramCrawler.new(instagram_params)
    #   insta.validate
    #   insta.manually_crawl
    # when 'twitter'
    #   twitter = Scrape::TwitterCrawler.new(twitter_params)
    #   twitter.validate
    #   twitter.manually_crawl
    # when 'official_site'
    #   site = Scrape::OfficialSiteCrawler.new(official_site_params)
    #   site.validate
    #   site.manually_crawl
    # when 'news_site'
    #   site = Scrape:: NewsSiteCrawler.new(news_site_params)
    #   site.manually_crawl
    # when 'youtube'
    #   youtube = Scrape::YoutubeCrawler.new(youtube_params)
    #   youtube.validate
    #   youtube.manually_crawl
    # end
  end
  
  private
  
  def media_exist?
    medias = %w(ameblo instagram twitter official_site news_site youtube)
    redirect_back fallback_location: scrape_index_path, alert: '登録されていないパラメータです' unless medias.include?(params[:media])
  end
  
  # それぞれ、tagもpermitする必要がありそう
  def ameblo_params
    params.permit(:member_id, :event_id).
      merge(params.require(:ameblo).permit(:article_url))
  end
  
  def instagram_params
    params.permit(:member_id, :event_id).
      merge(params.require(:instagram).permit(:article_url))
  end
  
  def twitter_params
    params.permit(:member_id, :event_id).
      merge(params.require(:twitter).permit(:type, :screen_name, :since, :until, :number, :tweet_url)).
      merge(user_type: :admin)
  end
  
  def official_site_params
    params.permit(:member_id, :event_id).
      merge(params.require(:official_site).permit(:page_url, :allowed_links, :depth_limit))
  end
  
  def news_site_params
    params.permit(:member_id, :event_id).
      merge(params.require(:news_site).permit(:article_url))
  end
  
  def youtube_params
    params.permit(:member_id, :event_id).
      merge(params.require(:youtube).permit(:youtube_url, :article_url))
  end
end
