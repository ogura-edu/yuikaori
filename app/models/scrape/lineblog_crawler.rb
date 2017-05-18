class Scrape::LineblogCrawler
  attr_accessor :errors
  
  def initialize(params)
    member_id = params[:member_id]
    event_id = params[:event_id]
    new_event = params[:event_attributes]
    tag_list = params[:tag_list]
    tmp = params[:tmp]
    @article_url = params[:article_url]
    @article_url.match %r{http://lineblog.me/(.+?)/archives/\d+?\.html} rescue nil
    @lineblogID = params[:lineblogID] || $1
    @host = "http://lineblog.me/#{@lineblogID}/"
    @downloader = Scrape::Downloader.new("lineblog/#{@lineblogID}/", member_id, event_id, new_event, tag_list, tmp)
  end
  
  def validate
    if @lineblogID.nil?
      @errors = '無効なURLです'
      return false
    elsif skip_IDs.include?(@lineblogID)
      @errors = '追跡済みのユーザは指定しないでください'
      return false
    end
    true
  end
  
  def crawl(type: :recent)
    case type
    when :all
      # 処理
      # ただし、アメブロからの移行前の分は取得しないように設定したい。
      # とりあえずは逐一（ymlファイルなどに記述するなどして）設定する。
    when :recent
      # 処理
    end
  end
  
  def manually_crawl
    # 処理
  end
  
  private
  
  # 例えば。
  def parse_article
  end
  
  def skip_IDs
    Settings.lineblog.regular_crawl.map{|obj| obj.ID}
  end
end
