class AllCrawl
  def self.execute
    self.ameblo
    self.instagram
    self.twitter
    self.official_site
  end
  
  def self.ameblo
    Settings.ameblo.stopped_updating.each do |obj|
      params = {
        amebaID:   obj.ID,
        member_id: obj.member_id,
        event_id:  1,
      }
      ameblo = Scrape::AmebloCrawler.new(params)
      ameblo.crawl(type: :all)
    end

    Settings.ameblo.regular_crawl.each do |obj|
      params = {
        amebaID:   obj.ID,
        member_id: obj.member_id,
        event_id:  1,
      }
      ameblo = Scrape::AmebloCrawler.new(params)
      ameblo.crawl(type: :all)
    end
  end

  def instagram
    Settings.instagram.regular_crawl.each do |obj|
      params = {
        instaID:   obj.ID,
        member_id: obj.member_id,
        event_id:  1,
      }
      insta = Scrape::InstagramCrawler.new(params)
      insta.crawl(type: :all)
    end
  end

  def twitter
    Settings.twitter.regular_crawl.each do |obj|
      params = {
        type:        'auto',
        screen_name: obj.ID,
        member_id:   obj.member_id,
        event_id:    1,
        user_type:   :admin,
      }
      twitter = Scrape::TwitterCrawler.new(params)
      twitter.crawl(type: :all)
    end
  end

  def official_site
    Settings.official_site.regular_crawl.each do |obj|
      params = {
        page_url:      obj.domain,
        allowed_links: obj.allowed,
        depth_limit:   false,
        member_id:     obj.member_id,
        event_id:      1,
      }
      site = Scrape::OfficialSiteCrawler.new(params)
      site.crawl
    end
  end
end
