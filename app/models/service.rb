class Service < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :hosts, through: :host_services
  has_many :host_services, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, length: { maximum: 255 }

  # To enable /services/:name instead of /services/:id
  def to_param
    name
  end

  def hosts_grouped_by_role
    hosts.reduce({}) do |grouped, host|
      roles = host.roles

      if roles.any?
        roles.each do |role|
          grouped[role.name] ||= []
          grouped[role.name] << host
        end
      else
        grouped['UNDEFINED'] ||= []
        grouped['UNDEFINED'] << host
      end

      grouped
    end
  end
end
