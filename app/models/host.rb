require 'hyperion/collectd'

class Host < ActiveRecord::Base
  attr_accessible :hostname, :ip_address, :host_services_attributes, :host_roles_attributes

  has_many :services, through: :host_services
  has_many :host_services, dependent: :destroy
  accepts_nested_attributes_for :host_services, allow_destroy: true, update_only: true, reject_if: ->(attrs) { attrs[:service_id].blank? }

  has_many :roles, through: :host_roles
  has_many :host_roles, dependent: :destroy
  accepts_nested_attributes_for :host_roles, allow_destroy: true, update_only: true, reject_if: ->(attrs) { attrs[:role_id].blank? }

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
    "/hosts/#{hostname}/graph?plugin=#{plugin}&type=#{type}"
  end
end
