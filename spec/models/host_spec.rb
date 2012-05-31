require 'spec_helper'

describe Host do
  let(:host) { create(:host) }
  before {}

  describe "attrs" do
    subject { host }

    [:hostname, :ip_address].each do |attr|
      it { should respond_to attr }
    end
  end

  describe "relation" do
    subject { host }

    [:services].each do |relation|
      it { should respond_to relation }
    end
  end

  describe 'relation' do
    context 'When no relation exists' do
      subject { host }
      specify { host.services.count.should == 0 }
    end

    context 'When some relation exists' do
      it 'should have services' do
        subject { host }

        2.times do |i|
          service = create(:service, name: "test #{i}", description: 'test')
          create(:host_service, host_id: host.id, service_id: service.id)
        end

        host.services.count.should == 2
      end
    end

    context 'When host deleted' do
      it 'should also delete relations' do
        subject { host }

        service  = create(:service)
        relation = create(:host_service, host_id: host.id, service_id: service.id)

        relation.should_not nil
        host.destroy
        relation.should nil
      end
    end
  end
end

describe 'Class Methods' do
  describe 'dangling_hosts()' do
    context 'when no host exists' do
      subject { Host }
      specify { Host.dangling_hosts.count.should == 0 }
    end

    context 'when a host which has no service exists' do
      subject { Host }
      before  { create(:host) }

      specify { Host.dangling_hosts.should_not nil }
      specify { Host.dangling_hosts.count == 1 }
    end

    context 'when a host which has a service exists' do
      subject { Host }
      before  {
        host     = create(:host)
        relation = create(:host_service, host_id: host.id, service_id: rand(2**32))
      }

      specify { Host.dangling_hosts.count.should == 0 }
    end
  end
end
