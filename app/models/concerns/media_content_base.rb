module MediaContentBase
  extend ActiveSupport::Concern
  
  included do
    validates :member_id, inclusion: { in: [1, 2, 3] }
    
    acts_as_taggable
    belongs_to :member
    belongs_to :event, optional: true
    accepts_nested_attributes_for :event, reject_if: :event_blank_or_exist?
    
    scope :pagenate,   ->(page_id) { page(page_id).per(50) }
    scope :desc_order, -> { order('date DESC') }
    scope :asc_order,  -> { order('date ASC') }
    scope :allowed,    -> { where(tmp: false, removed: false).to_ary }
    scope :temporary,  -> { where(tmp: true,  removed: false).to_ary }
    scope :selected_by_date,   ->(params) { where('date >= ? AND date <= ?', params[:since], params[:until]) }
    scope :selected_by_member, ->(params) { joins(:member).merge(Member.id_is params[:member]) }
    scope :selected_by_event,  ->(params) { joins(:event).merge(Event.name_like params[:event]) }
    scope :selected_by_tag,    ->(params) { tagged_with(params[:tag], any: true, wild: true) }
    scope :selected_by_media,  ->(params) { where('address LIKE ?', "%#{params[:media]}%") }
  end
  
  def s3_address
    attributes['address'].gsub(Settings.media.root, '')
  end
  
  private
  
  def event_blank_or_exist?(attributes)
    return true if attributes[:name].blank? || Event.where(name: attributes[:name]).any?
    false
  end
end
