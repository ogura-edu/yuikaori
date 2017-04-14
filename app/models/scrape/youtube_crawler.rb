class Scrape::YoutubeCrawler
  def initialize(url, article_url)
    @uri = Addressable::URI.parse(url)
    @article_uri = Addressable::URI.parse(article_url) || @uri
    @downloader = Scrape::Downloader.new('')
  end
  
  def validate
    raise ArgumentError, 'URLが正しくありません' unless @uri.to_s.match(Regexp.escape('https://www.youtube.com/watch'))
  end
  
  def manually_crawl(params:)
    q_hash = Hash[URI.decode_www_form(@uri.query)]
    id = q_hash['v']
    @downloader.save_youtube(id, @uri, @article_uri, params[:member_id], params[:event_id], true)
  end
end
