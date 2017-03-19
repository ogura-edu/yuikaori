class Picture < ApplicationRecord
  has_and_belongs_to_many :tags
  belongs_to :member
  belongs_to :event
end
