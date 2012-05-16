require 'spec_helper'

describe "Services" do
  context "When users" do
    let(:service) { Service.create(:name => 'test', :description => 'test') }

    describe "GET /" do
      it "works!" do
        get services_path
        response.status.should be(200)
      end
    end

    describe "GET /services" do
      it "works!" do
        get services_path
        response.status.should be(200)
      end
    end

    describe "GET /services/:id" do
      it "works!" do
        get service_path(service.id)
        response.status.should be(200)
      end
    end

    describe "GET /services/new" do
      it "works!" do
        get new_service_path
        response.status.should be(200)
      end
    end

    describe "GET /services/:id/edit" do
      it "works!" do
        get edit_service_path(service.id)
        response.status.should be(200)
      end
    end

    describe "POST /services" do
      it "works!" do
        post services_path, :name => 'test', :description => 'test'
        response.status.should be(302)
      end
    end

    describe "PUT /services/:id" do
      it "works!" do
        put service_path(service.id), :name => 'updated', :description => 'updated'
        response.status.should be(302)
      end
    end

    describe "DELETE /services/:id" do
      it "works!" do
        delete service_path(service.id), :name => 'updated', :description => 'updated'
        response.status.should be(302)
      end
    end
  end

  context "When guests" do
  end
end
