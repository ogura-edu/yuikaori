class ScrapeController < ApplicationController
  def index
  end
  
  def ameblo
  end

  def instagram
  end

  def twitter
  end
  
  def scrape
    amebaID = params[:article_url].gsub(%r{http://ameblo.jp/(.*?)/.*}, '\1')
    dir_name = "manually/ameblo/#{amebaID}/"
    
    # amebaIDにゆいかおりブログが指定されたらエラーを吐くように
    if %w(ogura-yui ogurayui-0815 ishiharakaori ishiharakaori-0806).include?(amebaID)
      raise ArgumentError, 'ゆいかおりのブログは指定しないでください'
    end
    
    # make directory
    unless Dir.exist?(Rails.root.join("app/assets/images/#{dir_name}"))
      Dir.mkdir(Rails.root.join("app/assets/images/#{dir_name}"))
      puts 'made a directory.'
    end
    
    ameblo = Scrape::Ameblo.new(amebaID, dir_name)
    ameblo.manually_crawl(params)
    
    redirect_to scrape_index_path
  end
end
