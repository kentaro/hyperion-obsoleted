require 'spec_helper'

describe "Services" do
  describe "GET /services" do
    it "works!" do
      get services_path
      response.status.should be(200)
    end
  end
end
