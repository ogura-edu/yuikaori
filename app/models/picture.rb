class Picture < MediaContent
  default_scope -> { where(content_type: :picture) }
end
