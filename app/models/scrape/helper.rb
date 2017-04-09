class Scrape::Helper
  def self.write_mode(url)
    "w:#{open(url).to_s.encoding.to_s}"
  end

  def self.mkdir(fullpath)
    dirpath = File.dirname(fullpath)
    unless File.exist?(dirpath)
      puts "made directory '#{dirpath}'"
      FileUtils.mkdir_p(dirpath)
    end
  end

  def self.fullpath(filepath)
    "#{Settings.media.root}#{filepath}"
  end
end
