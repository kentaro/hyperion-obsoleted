require 'spec_helper'

describe Service do
  let(:service) { create(:service) }
  before {}

  describe "attrs" do
    subject { service }

    [:name, :description].each do |attr|
      it { should respond_to attr }
    end
  end

  describe "relation methods" do
    subject { service }

    [:hosts, :host_services].each do |relation|
      it { should respond_to relation }
    end
  end

  describe 'relation' do
    context 'When no relation exists' do
      subject { service }
      specify { service.hosts.count.should == 0 }
    end

    context 'When some relation exists' do
      it 'should have a host' do
        subject { service }

        2.times do |i|
          host = create(:host)
          create(:host_service, host_id: host.id, service_id: service.id)
        end

        service.hosts.count.should == 2
      end
    end

    context 'When service deleted' do
      it 'should also delete relations' do
        subject { service }

        host     = create(:host)
        relation = create(:host_service, host_id: host.id, service_id: service.id)

        relation.should_not nil
        service.destroy
        relation.should nil
      end
    end
  end
end
