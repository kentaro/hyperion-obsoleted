require 'spec_helper'

describe HostService do
  let(:relation) { create(:host_service) }
  before {}

  describe "attrs" do
    subject { relation }

    [:host_id, :service_id].each do |attr|
      it { should respond_to attr }
    end
  end

  describe "relation" do
    subject { relation }

    [:host, :service].each do |relation|
      it { should respond_to relation }
    end
  end
end
