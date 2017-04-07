class Scrape::OfficialSiteCrawler
  def initialize(url, *domains)
    url = url.gsub(/$/, '/') unless url =~ /\/$/
    uri = URI.parse(url)
    @top_page = uri
    @accept_domains = [ url, domains ].flatten
    @downloader = Scrape::Downloader.new("official_site/#{uri.host}#{uri.path}")
  end
  
  def validate
    raise ArgumentError, '追跡済みのURLは指定しないでください' if skip_domains.include?(@top_page.host)
  end
  
  def crawl(member_id:, type: :recent)
    s = Time.now
    options = {
      depth_limit: 2,
      delay: 2,
      # proxy_host: 'localhost',
      # proxy_port: '5432',
      obey_robots_txt: true,
      storage: Anemone::Storage.PStore("tmp/anemone/#{@top_page.host}.dmp")
    }
    Anemone.crawl(@top_page, options) do |anemone|
      anemone.focus_crawl do |page|
        page.links.keep_if do |link|
          @accept_domains.each do |domain|
            link.to_s.match(domain)
          end
        end
      end
      
      anemone.on_every_page do |page|
        puts '-----------------------------------------------'
        puts "checking #{page.url}..."
        doc = Nokogiri::HTML.parse(page.body)
        doc.xpath('//img').each do |a_tag|
          image_url = a_tag.attribute('src')
          uri = URI.parse(image_url)
          path = "app/assets/images/official_site/#{uri.host}#{uri.path}"
          
          if File.exist?(path)
            puts 'already exist'
            next
          elsif !(Settings.extname.images.include?(File.extname(image_url)))
            puts 'not jpg or png'
            next
          elsif !(FileTest.exist?(File.dirname(path)))
            puts 'made directory'
            FileUtils.mkdir_p(File.dirname(path))
          end
          
          puts "download #{image_url}"
          open(path, Scrape::Helper.write_mode(image_url)) do |output|
            open(image_url) do |data|
              output.write(data.read)
            end
          end
        end
        doc.xpath('//link[@rel="stylesheet"]').each do |link_tag|
          puts link_tag.attribute('href')
        end
        # if Settings.extname.images.include?(File.extname(page.url.to_s))
      end
    end
    puts Time.now - s
  end
  
  def manually_crawl(params:)
    
  end
  
  private
  
  def a
    a
  end
  
  def a
    a
  end
  
  def skip_domains
    Settings.official_site.regular_crawl.map{|obj| obj.domain}
  end
end
