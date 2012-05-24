class HostRole < ActiveRecord::Base
  attr_accessible :host_id, :role_id

  belongs_to :host
  belongs_to :role
end
