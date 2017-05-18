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
  end
  
  private
  
  def media_exist?
    medias = %w(lineblog ameblo instagram twitter official_site news_site youtube)
    redirect_back fallback_location: scrape_index_path, alert: '登録されていないパラメータです' unless medias.include?(params[:media])
  end
  
  def lineblog_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:lineblog).permit(:article_url)).
      merge(tmp: true)
  end
  
  def ameblo_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:ameblo).permit(:article_url)).
      merge(tmp: true)
  end
  
  def instagram_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:instagram).permit(:article_url)).
      merge(tmp: true)
  end
  
  def twitter_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:twitter).permit(:type, :screen_name, :since, :until, :number, :tweet_url)).
      merge(tmp: true, user_type: :admin)
  end
  
  def official_site_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:official_site).permit(:page_url, :allowed_links, :depth_limit)).
      merge(tmp: true)
  end
  
  def news_site_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:news_site).permit(:article_url)).
      merge(tmp: true)
  end
  
  def youtube_params
    params.permit(:member_id, :event_id, :tag_list, event_attributes: [:name]).
      merge(params.require(:youtube).permit(:youtube_url, :article_url)).
      merge(tmp: true)
  end
end
