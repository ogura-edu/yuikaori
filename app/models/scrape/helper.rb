class Scrape::Helper
  def self.write_mode(url)
    "w:#{open(url).to_s.encoding.to_s}"
  end

  def self.mkdir_if_not_exist(fullpath)
    dir_name = File.dirname(fullpath)
    Dir.mkdir(dir_name) unless Dir.exist?(dir_name)
  end
end
