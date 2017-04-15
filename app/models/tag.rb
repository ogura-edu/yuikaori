class Tag < ApplicationRecord
  has_and_belongs_to_many :pictures
  has_and_belongs_to_many :videos
end
