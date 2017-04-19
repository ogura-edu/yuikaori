class AllCrawl
  def self.execute
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

    Settings.instagram.regular_crawl.each do |obj|
      params = {
        instaID:   obj.ID,
        member_id: obj.member_id,
        event_id:  1,
      }
      insta = Scrape::InstagramCrawler.new(params)
      insta.crawl(type: :all)
    end

    Settings.twitter.regular_crawl.each do |obj|
      params = {
        type:        'auto',
        screen_name: obj.ID,
        member_id:   obj.member_id,
        event_id:    1,
      }
      twitter = Scrape::TwitterCrawler.new(params, user_type: :admin)
      twitter.crawl(type: :all)
    end

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
