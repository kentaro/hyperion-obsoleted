class HostService < ActiveRecord::Base
  attr_accessible :host_id, :service_id

  belongs_to :host
  belongs_to :service
end
