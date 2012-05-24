require 'hyperion/collectd'

class GraphController < ApplicationController
  def show
    rrd = Hyperion::Collectd.new.rrd_for params[:hostname], params[:plugin], params[:type]
    send_file rrd.graph, type: 'image/png', disposition: 'inline'
  end
end
