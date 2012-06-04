require 'hyperion/collectd'

class HostsController < ApplicationController
  def index
    @hosts = Host.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hosts }
    end
  end

  def show
    @host = Host.find_by_hostname(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @host }
    end
  end

  def new
    @host = Host.new
    @host.host_services.build
    @host.host_roles.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @host }
    end
  end

  def edit
    @host = Host.find_by_hostname(params[:id])
    @host.host_services.empty? && @host.host_services.build
    @host.host_roles.empty?    && @host.host_roles.build
  end

  def create
    @host = Host.new(params[:host])

    respond_to do |format|
      if @host.save
        format.html { redirect_to @host, notice: 'Host was successfully created.' }
        format.json { render json: @host, status: :created, location: @host }
      else
        format.html { render action: "new" }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @host = Host.find_by_hostname(params[:id])

    respond_to do |format|
      if @host.update_attributes(params[:host])
        format.html { redirect_to @host, notice: 'Host was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @host = Host.find_by_hostname(params[:id])
    @host.destroy

    respond_to do |format|
      format.html { redirect_to hosts_url }
      format.json { head :no_content }
    end
  end

  def graph
    @host = Host.find_by_hostname(params[:id])

    rrd = Hyperion::Collectd.new.rrd_for @host.hostname, params[:plugin], params[:type]
    send_file rrd.graph, type: 'image/png', disposition: 'inline'
  end
end
