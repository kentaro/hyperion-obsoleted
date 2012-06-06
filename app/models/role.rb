class Role < ActiveRecord::Base
  attr_accessible :name, :description

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 255 }
end
