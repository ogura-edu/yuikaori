class Picture < MediaContent
  default_scope -> { where(content_type: 1) }
end
