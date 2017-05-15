class MediaContent < ApplicationRecord
  enum content_type: {
    picture: 1,
    video: 2,
  }
  validates :member_id, inclusion: { in: [1, 2, 3] }
  
  acts_as_taggable
  belongs_to :member
  belongs_to :event, optional: true
  accepts_nested_attributes_for :event, reject_if: :event_blank_or_exist?
  
  scope :paginate,   ->(page_id) { page(page_id).per(50) }
  scope :desc_order, -> { order('date DESC') }
  scope :asc_order,  -> { order('date ASC') }
  scope :allowed,    -> { where(tmp: false, removed: false) }
  scope :temporary,  -> { where(tmp: true,  removed: false) }
  scope :selected_by_date,   ->(params) { where('date >= ? AND date <= ?', params[:since], params[:until]).allowed }
  scope :selected_by_member, ->(params) { joins(:member).merge(Member.id_is params[:member]).allowed }
  scope :selected_by_event,  ->(params) { joins(:event).merge(Event.name_like params[:event]).allowed }
  scope :selected_by_tag,    ->(params) { tagged_with(params[:tag], any: true, wild: true).allowed }
  scope :selected_by_media,  ->(params) { where('address LIKE ?', "%#{params[:media]}%").allowed }
  
  # class methods
  def self.remove(ids)
    media_contents = where(id: ids)
    media_contents.update_all(removed: true)
    media_contents.each do |media_content|
      media_content.delete_from_storage
    end
  end
  
  # instance methods
  def delete_from_storage
    begin
      case content_type
      when 'picture'
        S3_BUCKET.object(s3_address).delete
      when 'video'
        S3_BUCKET.object(s3_address).delete
        S3_BUCKET.object(s3_ss_address).delete
      end
    rescue
      puts $!
      puts "#{media_content.address} is maybe not exists."
    end
  end
  
  def thumbnail
    case content_type
    when 'picture'
      attributes['address']
    when 'video'
      ss_address
    end
  end
  
  private
  
  def s3_address
    attributes['address'].gsub(ENV['S3_BUCKET_URL'], '')
  end
  
  def ss_address
    attributes['address'].gsub(%r{\.[^.]*?$}, '.jpg')
  end
  
  def s3_ss_address
    s3_address.gsub(%r{\.[^.]*?$}, '.jpg')
  end
  
  def event_blank_or_exist?(attributes)
    if attributes[:name].blank? || Event.where(name: attributes[:name]).any?
      return true
    end
    return false
  end
end
