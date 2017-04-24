class Member < ApplicationRecord
  has_many :pictures
  has_many :videos

  def self.id_is(id)
    where(id: id)
  end
end
