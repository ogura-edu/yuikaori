class Picture < ApplicationRecord
  has_and_belongs_to_many :tags
  belongs_to :member
  belongs_to :event
  accepts_nested_attributes_for :tags, reject_if: :tag_blank_or_exist?
  accepts_nested_attributes_for :event, reject_if: :event_blank_or_exist?

  def s3_address
    attributes['address'].gsub(Settings.media.root, '')
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

  private

  def event_blank_or_exist?(attributes)
    return true if attributes[:event].blank? || Event.where(event: attributes[:event]).any?
    false
  end

  def tag_blank_or_exist?(attributes)
    return true if attributes[:tag].blank? || Tag.where(tag: attributes[:tag]).any?
    false
  end
end
