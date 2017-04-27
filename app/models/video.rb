class Video < ApplicationRecord
  validates :member_id, inclusion: { in: [1, 2, 3] }
  
  acts_as_taggable
  belongs_to :member
  belongs_to :event, optional: true
  accepts_nested_attributes_for :event, reject_if: :event_blank_or_exist?
  
  def s3_address
    attributes['address'].gsub(Settings.media.root, '')
  end
  
  def s3_ss_address
    s3_address.gsub(%r{\.[^.]*?$}, '.jpg')
  end
  
  def ss_address
    attributes['address'].gsub(%r{\.[^.]*?$}, '.jpg')
  end
  
  def screenshot
    ss = S3_BUCKET.object(s3_ss_address)
    tmp_ss = "tmp/screenshot.jpg"
    if ss.exists?
      puts "screenshot #{ss_address} already exists."
      return
    end
    movie = FFMPEG::Movie.new(address)
    movie.screenshot(tmp_ss)
    ss.put(body: File.open(tmp_ss))
    File.delete(tmp_ss)
  end

  def self.allowed
    where(tmp: false, removed: false)
  end
  
  def self.temporary
    where(tmp: true, removed: false)
  end

  def self.selected_by_date(params)
    where('date >= ? AND date <= ?', params[:since], params[:until]).allowed
  end

  def self.selected_by_member(params)
    joins(:member).merge(Member.id_is params[:member]).allowed
  end

  def self.selected_by_event(params)
    joins(:event).merge(Event.name_like params[:event]).allowed
  end
  
  def self.selected_by_tag(params)
    tagged_with(params[:tag], any: true, wild: true).allowed
  end

  def self.selected_by_media(params)
    where('address LIKE ?', "%#{params[:media]}%").allowed
  end

  private
  
  def event_blank_or_exist?(attributes)
    return true if attributes[:name].blank? || Event.where(name: attributes[:name]).any?
    false
  end
end
