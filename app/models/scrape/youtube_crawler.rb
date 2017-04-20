class Scrape::YoutubeCrawler
  attr_accessor :errors
  
  def initialize(params)
    @member_id = params[:member_id]
    @event_id = params[:event_id]
    @uri = Addressable::URI.parse(params[:youtube_url])
    @article_uri = Addressable::URI.parse(params[:article_url]) || @uri
    @downloader = Scrape::Downloader.new('')
  end
  
  def validate
    if !@uri.to_s.match(%r{https://www.youtube.com/watch})
      @errors =  '無効なURLです'
      return false
    end
    true
  end
  
  def manually_crawl
    q_hash = Hash[URI.decode_www_form(@uri.query)]
    id = q_hash['v']
    @downloader.save_youtube(id, @uri, @article_uri, @member_id, @event_id, true)
  end
end
