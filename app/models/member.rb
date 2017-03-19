class Member < ApplicationRecord
  has_many :pictures
  has_many :videos
end
