class Service < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :hosts, through: :host_services
  has_many :host_services, dependent: :destroy

  # To enable /services/:name instead of /services/:id
  def to_param
    name.to_s
  end
end
