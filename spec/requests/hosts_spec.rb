require 'spec_helper'

describe "Hosts" do
  context "When users" do
    before { @host = Host.create(hostname: 'test', ip_address: '192.168.0.1') }

    describe "GET /hosts" do
      it "works!" do
        get hosts_path
        response.status.should be(200)
      end
    end

    describe "GET /hosts/:id" do
      it "works!" do
        get host_path(@host)
        response.status.should be(200)
      end
    end

    describe "GET /hosts/new" do
      it "works!" do
        get new_host_path
        response.status.should be(200)
      end
    end

    describe "GET /hosts/:id/edit" do
      it "works!" do
        get edit_host_path(@host)
        response.status.should be(200)
      end
    end

    describe "POST /hosts" do
      it "works!" do
        post hosts_path, 'host[hostname]' => 'test2', 'host[ip_address]' => '192.168.0.2'
        response.status.should be(302)
      end
    end

    describe "PUT /hosts/:id" do
      it "works!" do
        put host_path(@host), 'host[hostname]' => 'test (updated)', 'host[ip_address]' => '192.168.0.1'
        response.status.should be(302)
      end
    end

    describe "DELETE /hosts/:id" do
      it "works!" do
        delete host_path(@host)
        response.status.should be(302)
      end
    end
  end

  context "When guests" do
  end
end
