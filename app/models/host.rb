class Host < ActiveRecord::Base
  attr_accessible :hostname, :ip_address

  has_many :services, through: :host_services
  has_many :host_services, dependent: :destroy
end
