require 'spec_helper'

describe Service do
  before { @service = Service.create(name: 'test', description: 'test') }

  describe "attrs" do
    subject { @service }

    [:name, :description].each do |attr|
      it { should respond_to attr }
    end
  end

  describe "relation methods" do
    subject { @service }

    [:hosts, :host_services].each do |relation|
      it { should respond_to relation }
    end
  end

  describe 'relation' do
    context 'When no relation exists' do
      it 'should has a host' do
        @service.hosts.count.should == 0
      end
    end

    context 'When some relation exists' do
      it 'should has a host' do
        count = 0

        [
          Host.create(hostname: "test #{count += 1}", ip_address: "192.168.0.#{count}"),
          Host.create(hostname: "test #{count += 1}", ip_address: "192.168.0.#{count}")
        ].each do |host|
          relation = HostService.create(host_id: host.id, service_id: @service.id)
        end

        @service.hosts.count.should == count
      end
    end

    context 'When service deleted' do
      it 'should also delete relations' do
        host     = Host.create(hostname: 'test', ip_address: '192.168.0.1')
        relation = HostService.create(host_id: host.id, service_id: @service.id)

        relation.should_not nil
        @service.destroy
        relation.should nil
      end
    end
  end
end
