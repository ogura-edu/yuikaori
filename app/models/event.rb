class Event < ApplicationRecord
  has_many :pictures
  has_many :videos

  def self.name_like(name)
    where("name LIKE ?", "%#{name}%")
  end
end
