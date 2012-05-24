require 'hyperion/collectd'

class Host < ActiveRecord::Base
  attr_accessible :hostname, :ip_address, :host_services_attributes

  has_many :services, through: :host_services
  has_many :host_services, dependent: :destroy

  accepts_nested_attributes_for :host_services, allow_destroy: true, reject_if: ->(attrs) { attrs[:service_id].blank? }

  class << self
    def dangling_hosts
      find(:all, include: :host_services, conditions: { host_services: { service_id: nil } })
    end
  end

  # To enable /host/:hostname instead of /hosts/:id
  def to_param
    hostname
  end

  def collectd
    @collectd ||= Hyperion::Collectd.new
  end

  def graphs
    collectd.plugins_for hostname
  end

  def graph_path_for (plugin, type, options = {})
    "/graph/#{hostname}/#{plugin}/#{type}"
  end
end
