require 'spec_helper'

describe "Services" do
  context "When users" do
    let(:service) { create(:service) }
    subject { page }

    describe "GET /" do
      it "works!" do
        get services_path
        response.should be_success
      end
    end

    describe "GET /services" do
      it "works!" do
        get services_path
        response.should be_success
      end
    end

    describe "GET /services/:name" do
      it "works!" do
        get service_path(service)
        response.should be_success
      end
    end

    describe "GET /services/new" do
      it "works!" do
        get new_service_path
        response.should be_success
      end
    end

    describe "GET /services/:name/edit" do
      it "works!" do
        get edit_service_path(service)
        response.should be_success
      end
    end

    describe "new_service_page" do
      context "when `return_to' query not exists" do
        let(:service_name) { "Test Service #{rand(2**32)}" }

        before {
          visit new_service_path
          fill_in 'Name',        with: service_name
          fill_in 'Description', with: 'desc for service'
          click_button 'Create Service'
        }

        it { should have_selector('h1', text: 'Service') }
      end

      context "when `return_to' query exists" do
        let(:service_name) { "Test Service #{rand(2**32)}" }

        before {
          visit new_service_path(return_to: '/')
          fill_in 'Name',        with: service_name
          fill_in 'Description', with: 'desc for service'
          click_button 'Create Service'
        }

        it { should have_selector('h1', text: 'Services') }
      end
    end

    describe "PUT /services/:name" do
      it "works!" do
        put service_path(service), 'service[name]' => 'updated', 'service[description]' => 'test'
        response.status.should be(302)
      end
    end

    describe "DELETE /services/:name" do
      it "works!" do
        delete service_path(service)
        response.status.should be(302)
      end
    end
  end

  context "When guests" do
  end
end
