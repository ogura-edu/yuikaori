Settings.instagram.regular_crawl.each do |obj|
  insta = Scrape::InstagramCrawler.new("https://www.instagram.com/#{obj.ID}/")
  insta.crawl(member_id: obj.member_id)
end
