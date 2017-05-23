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
      parse_all_articles
    when :recent
      recent_articles.each do |article|
        doc = Nokogiri::HTML.parse(open(article.at_css('link').text))
        parse_article(doc.at_css('article'))
      end
    end
  end
  
  def manually_crawl
    doc = Nokogiri::HTML.parse(open(@article_url)).at_xpath('//article')
    parse_article(doc)
  end
  
  private
  
  def crawl_archives(archive_url)
    doc = Nokogiri::HTML.parse(open(archive_url))
    doc.css('article').each do |article|
      parse_article(article)
    end
    unless doc.css('li.paging-next').empty?
      crawl_archives(doc.css('li.paging-next a').attribute('href').value)
    end
  end
  
  # 全記事の取得はarchives/YYYY-MM.html?p=:numで各記事をさらっていくしかないか。
  # 2017/05/17以前のブログデータはlineblogからは取得しない方針で。
  # 各ページで、li.paging-next要素の有無で次ページの有無を判定
  def parse_all_articles
    # 2017/05から現在までの全ての月についてeachを回す
    date = Date.new(2017, 5)
    till = Date.today
    while date < till do
      archive_url = "http://lineblog.me/#{@lineblogID}/archives/#{date.year}-#{format('%02d', date.month)}.html"
      crawl_archives(archive_url)
      
      date = date.next_month
    end
  end
  
  # 更新情報はindex.rdfに最新１５件が表示される。
  def recnet_articles
    # rdfから取得したitem要素の配列を返す
    doc = Nokogiri::XML.parse(open("http://lineblog.me/#{@lineblogID}/index.rdf"))
    articles = doc.css('item')
  end
  
  # 記事URLのみを集めたような一覧ページがないため、記事URLを指定するようなparseメソッドは賢くない
  # 幸い、各記事はarticle要素でまとめられているため、Nokogiriでパースした要素をこのメソッドに渡すことにする
  # 厄介なことに、instagramに投稿した記事をLINEblogでも記事として表示してくるクソ仕様なので、「ブログ」タグがないものをスキップするようにする
  def parse_article(doc)
    article_url = doc.xpath('//header//a').attribute('href').value
    date = Time.parse(doc.xpath('//time').attribute('datetime').value)
    return if date < Date.new(2017, 05, 18)
    return if # ブログタグがない場合
    doc.xpath('//div[@class="article-body-inner"]//a/img').each do |img|
      # imgタグのsrc属性の値を取り出すが、どのように加工すれば最大サイズの画像を適切に取得できるかは要検討
      # なお、拡張子は指定されていない模様。alt属性の値にある拡張子を参考にするのが良さそうか？
      image_url = img.attribute('src').value.gsub()
      next if # alt属性の拡張子が.gifだった場合
      
      @downloader.save_media(:image, image_url, article_url, date)
    end
  end
  
  def skip_IDs
    Settings.lineblog.regular_crawl.map{|obj| obj.ID}
  end
end
