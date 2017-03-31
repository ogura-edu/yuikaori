class RegularCrawl
  def self.execute
    Settings.ameblo.regular_crawl.each do |obj|
      ameblo = Scrape::AmebloCrawler.new("http://ameblo.jp/#{obj.ID}/")
      ameblo.crawl(member_id: obj.member_id)
    end

    Settings.instagram.regular_crawl.each do |obj|
      insta = Scrape::InstagramCrawler.new("https://www.instagram.com/#{obj.ID}/")
      insta.crawl(member_id: obj.member_id)
    end

    Settings.twitter.regular_crawl.each do |obj|
      twitter = Scrape::TwitterCrawler.new(user_type: :admin)
      twitter.crawl(screen_name: obj.ID, member_id: obj.member_id)
    end
  end
end
