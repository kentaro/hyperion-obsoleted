require 'spec_helper'

describe Host do
  before { @host = Host.create(hostname: 'test', ip_address: '127.0.0.1') }

  describe "attrs" do
    subject { @host }

    [:hostname, :ip_address].each do |attr|
      it { should respond_to attr }
    end
  end

  describe "relation" do
    subject { @host }

    [:services].each do |relation|
      it { should respond_to relation }
    end
  end

  describe 'relation' do
    context 'When no relation exists' do
      it 'should has a host' do
        @host.services.count.should == 0
      end
    end

    context 'When some relation exists' do
      it 'should have services' do
        count = 0

        [
          Service.create(name: "test #{count += 1}", description: 'test'),
          Service.create(name: "test #{count += 1}", description: 'test')
        ].each do |service|
          relation = HostService.create(host_id: @host.id, service_id: service.id)
        end

        @host.services.count.should == count
      end
    end

    context 'When host deleted' do
      it 'should also delete relations' do
        service  = Service.create(name: 'test', description: 'test')
        relation = HostService.create(host_id: @host.id, service_id: service.id)

        relation.should_not nil
        @host.destroy
        relation.should nil
      end
    end
  end
end
