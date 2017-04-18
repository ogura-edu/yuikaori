class Video < ApplicationRecord
  has_and_belongs_to_many :tags
  belongs_to :member
  belongs_to :event
  
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

  def self.selected_by_date(params)
    where('date >= ? AND date <= ? AND tmp IS false AND removed IS false', params[:since], params[:until])
  end

  def self.selected_by_member(params)
    where('member_id = ? AND tmp IS false AND removed IS false', params[:member])
  end

  def self.selected_by_event(params)
    event_ids = Event.where('event LIKE ?', "%#{params[:event]}%").ids
    where('event_id IN (?) AND tmp IS false AND removed IS false', event_ids)
  end
  
  def self.selected_by_tag(params)
    tag_ids = Tag.where('tag LIKE ?', "%#{params[:tag]}%").ids
    where('tag_id IN (?) AND tmp IS false AND removed IS false', tag_ids)
  end

  def self.selected_by_media(params)
    where('address LIKE ? AND tmp IS false AND removed IS false', "%#{params[:media]}%")
  end
end
