require 'spec_helper'
require 'hyperion/collectd'

COLLECTD_BASE_DIR = 'spec/assets/collectd/rrd'
Hyperion::Collectd::COLLECTD_BASE_DIR = COLLECTD_BASE_DIR

describe Hyperion::Collectd do
  describe 'initialize()' do
    context 'when correct base_dir passed' do
      let(:collectd) { Hyperion::Collectd.new COLLECTD_BASE_DIR }

      subject { collectd }

      it { should_not be_nil }
      its(:base_dir) { should == COLLECTD_BASE_DIR }
    end

    context 'when base_dir not passed correctly' do
      context 'when no dir passed' do
        it 'should not raise exception' do

          lambda { Hyperion::Collectd.new }.should_not raise_exception
          Hyperion::Collectd.new.base_dir.should == Hyperion::Collectd::COLLECTD_BASE_DIR
        end
      end

      context 'when a dir which does not exists' do
        it 'should raise exception' do
          lambda { Hyperion::Collectd.new '/no/such/dir' }.should raise_exception
        end
      end
    end
  end

  describe 'methods' do
    let(:collectd) { Hyperion::Collectd.new COLLECTD_BASE_DIR }

    context 'when some hosts are under base_dir' do
      describe 'hosts()' do
        let(:hosts) { collectd.hosts }

        subject { hosts }

        it { should_not be_nil }
        its(:size) { should > 0 }
        it 'holds instances of Hyperion::Collectd::Host' do
          hosts.each do |host|
            host.should be_an_instance_of Hyperion::Collectd::Host
          end
        end
      end

      describe 'plugins_for()' do
        let(:plugins) { collectd.plugins_for('test.example.com') }

        subject { plugins }

        it { should_not be_nil }
        its(:size) { should > 0 }
        it 'holds instances of Hyperion::Collectd::Host' do
          plugins.each do |host|
            host.should be_an_instance_of Hyperion::Collectd::Plugin
          end
        end
      end

      describe 'rrd_for()' do
        let(:rrd) { collectd.rrd_for('test.example.com', 'cpu', 'user') }

        subject { rrd }

        it { should_not be_nil }
        it { should be_an_instance_of Hyperion::Collectd::RRD }
      end
    end
  end

  describe Hyperion::Collectd::Host do
    describe 'initialize()' do
      context 'when argument passed correctly' do
        subject { Hyperion::Collectd::Host.new('test.example.com', COLLECTD_BASE_DIR + '/test.example.com') }

        its(:name) { should == 'test.example.com' }
        its(:path) { should == COLLECTD_BASE_DIR + '/test.example.com' }
      end
    end

    describe 'plugins()' do
      context 'when some plugins are under base_dir' do
        before  {
          @plugins = Hyperion::Collectd::Host.new(
            'test.example.com',
            COLLECTD_BASE_DIR + '/test.example.com'
          ).plugins
        }
        subject { @plugins }

        it { should_not == nil }
        its(:size) { should > 0  }
        it 'holds instances of Hyperion::Collectd::Plugin' do
          @plugins.each do |plugin|
            plugin.should be_an_instance_of Hyperion::Collectd::Plugin
          end
        end
      end
    end
  end

  describe Hyperion::Collectd::Plugin do
    describe 'initialize()' do
      context 'when argument passed correctly' do
        subject { Hyperion::Collectd::Plugin.new('test.example.com', 'cpu', COLLECTD_BASE_DIR + '/test.example.com/cpu-0') }

        its(:host) { should == 'test.example.com' }
        its(:name) { should == 'cpu' }
        its(:path) { should == COLLECTD_BASE_DIR + '/test.example.com/cpu-0' }
      end
    end

    describe 'rrds()' do
      context 'when some rrds are under base_dir' do
        before  {
          @rrds = Hyperion::Collectd::Plugin.new('test.example.com', 'cpu', COLLECTD_BASE_DIR + '/test.example.com/cpu-0').rrds }
        subject { @rrds }

        it { should_not == nil   }
        its(:size) { should > 0  }
        it 'holds instances of Hyperion::Collectd::RRD' do
          @rrds.each do |rrd|
            rrd.should be_an_instance_of Hyperion::Collectd::RRD
          end
        end
      end
    end
  end

  describe Hyperion::Collectd::RRD do
    describe 'initialize()' do
      context 'when argument passed correctly' do
        subject { Hyperion::Collectd::RRD.new('cpu', 'user', COLLECTD_BASE_DIR + '/test.example.com/cpu-0/cpu-user.rrd') }

        its(:plugin) { should == 'cpu' }
        its(:name)   { should == 'user' }
        its(:path)   { should == COLLECTD_BASE_DIR + '/test.example.com/cpu-0/cpu-user.rrd' }
      end
    end

    describe 'graph()' do
      context 'when graph definition found' do
        let(:rrd) { Hyperion::Collectd::RRD.new('cpu', 'user', COLLECTD_BASE_DIR + '/test.example.com/cpu-0/cpu-user.rrd') }

        subject { rrd.graph }

        it { should == "#{Hyperion::Collectd::GRAPH_BASE_DIR}/cpu-user.png" }
      end

      context 'when graph definition not found' do
        let(:rrd) { Hyperion::Collectd::RRD.new('cpu', 'user', 'no-such-rrd') }

        subject { rrd.graph }

        it { should be_false }
      end
    end
  end
end
