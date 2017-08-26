namespace :crawl do
  namespace :all do
    desc 'crawl all images for all media'
    task all: :environment do
      AllCrawl.execute
    end
    
    desc 'crawl all images for ameblo'
    task ameblo: :environment do
      AllCrawl.ameblo
    end
    
    desc 'crawl all images for line blog'
    task lineblog: :environment do
      AllCrawl.lineblog
    end
    
    desc 'crawl all images for instagram'
    task instagram: :environment do
      AllCrawl.instagram
    end
    
    desc 'crawl all images for twitter'
    task twitter: :environment do
      AllCrawl.twitter
    end
    
    desc 'crawl all images for official_site'
    task official_site: :environment do
      AllCrawl.official_site
    end
  end
  
  namespace :regular do
    desc 'crawl recent images for all media'
    task all: :environment do
      RegularCrawl.execute
    end
    
    desc 'crawl recent images for ameblo'
    task ameblo: :environment do
      RegularCrawl.ameblo
    end
    
    desc 'crawl recent images for line blog'
    task lineblog: :environment do
      RegularCrawl.lineblog
    end
    
    desc 'crawl recent images for instagram'
    task instagram: :environment do
      RegularCrawl.instagram
    end
    
    desc 'crawl recent images for twitter'
    task twitter: :environment do
      RegularCrawl.twitter
    end
  end
end
