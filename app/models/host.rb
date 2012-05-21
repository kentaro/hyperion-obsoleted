class Host < ActiveRecord::Base
  attr_accessible :hostname, :ip_address, :host_services_attributes

  has_many :services, through: :host_services
  has_many :host_services, dependent: :destroy

  accepts_nested_attributes_for :host_services, allow_destroy: true, reject_if: ->(attrs) { attrs[:service_id].blank? }

  # To enable /host/:hostname instead of /hosts/:id
  def to_param
    hostname
  end

  def self.dangling_hosts
    find(:all, include: :host_services, conditions: { host_services: { service_id: nil } })
  end
end
