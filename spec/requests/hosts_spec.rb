require 'spec_helper'

describe "Hosts" do
  context "When users" do
    let(:host) { create(:host) }
    before { }

    describe "GET /hosts" do
      it "works!" do
        get url_for controller: 'hosts', action: 'index'
        response.should be_success
      end
    end

    describe "GET /hosts/:hostname" do
      it "works!" do
        get host_path(host)
        response.should be_success
      end
    end

    describe "GET /hosts/new" do
      it "works!" do
        get new_host_path
        response.should be_success
      end
    end

    describe "GET /hosts/:hostname/edit" do
      it "works!" do
        get edit_host_path(host)
        response.should be_success
      end
    end

    describe "POST /hosts" do
      it "works!" do
        post hosts_path, 'host[hostname]' => 'test2.example.com', 'host[ip_address]' => '192.168.0.2'
        response.status.should be(302)
      end
    end

    describe "POST /hosts/:hostname" do
      it "works!" do
        put host_path(host), 'host[hostname]' => 'test2.example.com', 'host[ip_address]' => '192.168.0.1'
        response.status.should be(302)
      end
    end

    describe "POST /hosts/:hostname" do
      it "works!" do
        delete host_path(host)
        response.status.should be(302)
      end
    end
  end

  context "When guests" do
  end
end
