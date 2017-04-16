class Scrape::Helper
  def self.write_mode(uri)
    "w:#{open(uri).to_s.encoding.to_s}"
  end

  def self.fullpath(filepath)
    "#{Settings.media.root}#{filepath}"
  end

  def self.url(page, src)
    if self.absolute_path?(src)
      src
    else
      base_uri = Addressable::URI.parse(page).normalize
      (base_uri + src).to_s
    end
  end

  def self.absolute_path?(str)
    Addressable::URI.parse(str).scheme != nil
  end
end
