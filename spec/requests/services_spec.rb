require 'spec_helper'

describe "Services" do
  context "When users" do
    before { @service = Service.create(name: 'test', description: 'test') }

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

    describe "GET /services/:name" do
      it "works!" do
        get service_path(@service)
        response.status.should be(200)
      end
    end

    describe "GET /services/new" do
      it "works!" do
        get new_service_path
        response.status.should be(200)
      end
    end

    describe "GET /services/:name/edit" do
      it "works!" do
        get edit_service_path(@service)
        response.status.should be(200)
      end
    end

    describe "POST /services" do
      it "works!" do
        post services_path, 'service[name]' => 'test2', 'service[description]' => 'test'
        response.status.should be(302)
      end
    end

    describe "PUT /services/:name" do
      it "works!" do
        put service_path(@service), 'service[name]' => 'updated', 'service[description]' => 'test'
        response.status.should be(302)
      end
    end

    describe "DELETE /services/:name" do
      it "works!" do
        delete service_path(@service)
        response.status.should be(302)
      end
    end
  end

  context "When guests" do
  end
end
