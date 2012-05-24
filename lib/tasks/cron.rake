require 'hyperion/collectd'

namespace :cron do
  task watch_host: :environment do
    collectd = Hyperion::Collectd.new
    collectd.hosts.each do |host|
      Host.where(hostname: host.name).first_or_create
    end
  end
end
