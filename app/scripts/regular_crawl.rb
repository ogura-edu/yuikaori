class RegularCrawl
  def self.execute
    self.lineblog
    self.ameblo
    self.instagram
    self.twitter
  end
  
  def self.lineblog
    Settings.lineblog.regular_crawl.each do |obj|
      params = {
        lineblogID: obj.ID,
        member_id:  obj.member_id,
        tmp:        false,
      }
      lineblog = Scrape::LineblogCrawler.new(params)
      lineblog.crawl
    end
  end

  def self.ameblo
    Settings.ameblo.regular_crawl.each do |obj|
      params = {
        amebaID:   obj.ID,
        member_id: obj.member_id,
        tmp:       false,
      }
      ameblo = Scrape::AmebloCrawler.new(params)
      ameblo.crawl
    end
  end

  def self.instagram
    Settings.instagram.regular_crawl.each do |obj|
      params = {
        instaID:   obj.ID,
        member_id: obj.member_id,
        tmp:       false,
      }
      insta = Scrape::InstagramCrawler.new(params)
      insta.crawl
    end
  end

  def self.twitter
    Settings.twitter.regular_crawl.each do |obj|
      params = {
        type:        'auto',
        screen_name: obj.ID,
        member_id:   obj.member_id,
        tmp:         false,
        user_type:   :admin,
      }
      twitter = Scrape::TwitterCrawler.new(params)
      twitter.crawl
    end
  end
end
