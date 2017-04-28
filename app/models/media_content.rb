class MediaContent
  # class methos
  def self.allowed
    [ Picture.allowed,
      Video.allowed ].flatten
  end
  
  def self.temporary
    [ Picture.temporary.concat,
      Video.temporary ].flatten
  end
  
  def self.selected_by_date(params)
    [ Picture.selected_by_date(params).allowed.concat,
      Video.selected_by_date(params).allowed
  end

  def self.selected_by_member(params)
    [ Picture.selected_by_member(params).allowed.concat,
      Video.selected_by_member(params).allowed
  end

  def self.selected_by_event(params)
    [ Picture.selected_by_event(params).allowed.concat,
      Video.selected_by_event(params).allowed
  end
  
  def self.selected_by_tag(params)
    [ Picture.selected_by_tag(params).allowed.concat,
      Video.selected_by_tag(params).allowed
  end

  def self.selected_by_media(params)
    [ Picture.selected_by_media(params).allowed.concat,
      Video.selected_by_media(params).allowed
  end
  
  def self.remove(picture_ids, video_ids)
    Picture.remove(picture_ids)
    Video.remove(video_ids)
  end
end
