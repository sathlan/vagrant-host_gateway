require 'spec_helper'

describe Vagrant::HostGateway::Middleware do
  let (:env)           { Vagrant::Action::Environment.new }
  let (:vm)            { double("Vagrant::VM").as_null_object }
  let (:app)           { double("Object").as_null_object }
  let (:ui)            { double("Vagrant::UI::Interface").as_null_object }
  let (:guest)         { double("Vagrant::HostGateway::Guest").as_null_object }
  let (:host)          { double("Vagrant::HostGateway::Host").as_null_object }
  let (:config)        { double("Object").as_null_object }
  let (:debian)        { Vagrant::Hosts::Linux.new(ui) }
  let (:debian_g)      { Vagrant::Guest::Linux.new(ui) }
  let (:windows)       { Vagrant::Hosts::Windows.new(ui) }
  let (:windows_g)     { Vagrant::Guest::Base.new(ui) }

  before :each do
    env[:vm] = vm
    env[:ui] = ui

    vm.stub(:config).and_return config

    app.stub(:call)

#    Vagrant::HostGateway::Guest.stub(:new).with(env).and_return(guest)
#    Vagrant::HostGateway::Host.stub(:new).with(env).and_return(host)
  end

  subject { Vagrant::HostGateway::Middleware.new(app, env) }

  describe '#call' do
    shared_examples "chained hostgateway middleware" do
      it "calls the next middleware" do
        app.should_receive(:call).with(env)

        subject.call(env)
      end
    end
    context "for supported host and guest system" do
      before :each do
        env[:host] = debian
        env[:vm].stub(:guest).and_return(debian_g)
      end
      context "with a gateway set" do
        before :each do
          config.stub_chain(:vm, :gateway).and_return('192.168.0.1')
        end
        context "and no snat on network interface" do
          before :each do
            config.stub_chain(:vm, :networks).and_return(
                                                         :hostonly => [
                                                           '10.0.0.2', { :netmask => '255.255.255.0' }
                                                           ])
          end
          it_behaves_like "chained hostgateway middleware"

          it 'should add the some methods to the guest' do
            subject.call(env)
            debian_g.methods.grep(:set_gateway).should_not be_empty
          end
          it 'should add the some methods to the host' do
            subject.call(env)
            debian.methods.grep(:setup_nat).should_not be_empty
            debian.methods.grep(:enable_forwarding).should_not be_empty
          end

          it 'should display the gateway' do
            ui.should_receive(:info).with("Setting gateway to 192.168.0.1")
            subject.call(env)
          end
          it 'should set the gateway' do
            debian_g.should_receive(:set_gateway).with('192.168.0.1')
            subject.call(env)
          end

          it 'should not try to set snat' do
            debian.should_not_receive(:enable_forwarding)
            debian.should_not_receive(:setup_nat)

            subject.call(env)
          end

        end

        context "with snat on network interface" do
          before :each do
            config.stub_chain(:vm, :networks).and_return(
                                                         :hostonly => [
                                                           '10.0.0.2', {
                                                             :netmask => '255.255.255.0',
                                                             :nat     => 'eth0'
                                                           },
                                                         ])
          end

          it 'should set snat' do
            debian.should_receive(:enable_forwarding)
            debian.should_receive(:setup_nat).with('eth0', '10.0.0.2/24')

            subject.call(env)
          end
        end
      end

      context 'with no gateway set' do
        before :each do
          config.stub_chain(:vm, :gateway).and_return(nil)
        end
        it 'should not try to set the gateway' do
          debian.should_not_receive(:set_gateway)
        end
      end
    end

    context "for unsupported guest and host system" do
      before :each do
        env[:host] = windows
        env[:vm].stub(:guest).and_return(windows_g)
      end
      context "with snat on network interface" do
        before :each do
          config.stub_chain(:vm, :networks).and_return(
                                                       :hostonly => [
                                                         '10.0.0.2', {
                                                           :netmask => '255.255.255.0',
                                                           :nat     => 'eth0'
                                                         },
                                                       ])
        end
        it 'should fails' do
          proc { subject.call(env) }.
            should raise_error(Vagrant::HostGateway::Guest::Unsupported,
                               /the guest OS \(\["Base"\]\)/)
        end
      end
    end

  end
end
