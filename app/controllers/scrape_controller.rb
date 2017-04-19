class ScrapeController < ApplicationController
  before_action :approved_user!
  
  def scrape
    # 別ページだしsubmitボタンのnameで分けなくても良さそう。case when使えそう
    # 各モデルの引数なども書き換える必要あり。initializeでインスタンス変数にする？
    case params[:media]
    when 'ameblo'
      ameblo = Scrape::AmebloCrawler.new(ameblo_params)
      ameblo.validate
      ameblo.manually_crawl
    when 'instagram'
      insta = Scrape::InstagramCrawler.new(instagram_params)
      insta.validate
      insta.manually_crawl
    when 'twitter'
      twitter = Scrape::TwitterCrawler.new(twitter_params, user_type: :admin)
      twitter.validate
      twitter.manually_crawl
    when 'official_site'
      site = Scrape::OfficialSiteCrawler.new(official_site_params)
      site.validate
      site.manually_crawl
    when 'news_site'
      site = Scrape:: NewsSiteCrawler.new(news_site_params)
      site.manually_crawl
    when 'youtube'
      youtube = Scrape::YoutubeCrawler.new(youtube_params)
      youtube.validate
      youtube.manually_crawl
    end
    redirect_to scrape_index_path
  end
  
  private
  # それぞれ、tagもpermitする必要がありそう
  
  def ameblo_params
    params.require(:ameblo).permit(:article_url)
    params.permit(:member_id, :event_id)
  end
  
  def instagram_params
    params.require(:instagram).permit(:article_url)
    params.permit(:member_id, :event_id)
  end
  
  def twitter_params
    params.require(:twitter).permit(:type, :screen_name, :since, :until, :number, :tweet_url)
    params.permit(:member_id, :event_id)
  end
  
  def official_site_params
    params.require(:official_site).permit(:page_url, :allowed_links, :depth_limit)
    params.permit(:member_id, :event_id)
  end
  
  def news_site_params
    params.require(:news_site).permit(:article_url)
    params.permit(:member_id, :event_id)
  end
  
  def youtube_params
    params.require(:youtube).permit(:youtube_url, :article_url)
    params.permit(:member_id, :event_id)
  end
end
