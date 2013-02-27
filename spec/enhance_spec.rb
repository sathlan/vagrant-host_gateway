require 'spec_helper'

describe Vagrant::HostGateway::Enhance do
  let (:env)           { Vagrant::Action::Environment.new }
  let (:vm)            { double("Vagrant::VM").as_null_object }
  let (:app)           { double("Object").as_null_object }
  let (:ui)            { double("Vagrant::UI::Interface").as_null_object }
  let (:guest)         { double("Vagrant::HostGateway::Guest").as_null_object }
  let (:host)          { double("Vagrant::HostGateway::Host").as_null_object }
  let (:config)        { double("Object").as_null_object }
  let (:debian)        { Vagrant::Hosts::Linux.new(ui) }
  let (:debian_g)      { Vagrant::Guest::Debian.new(ui) }
  let (:windows)       { Vagrant::Hosts::Windows.new(ui) }
  let (:windows_g)     { Vagrant::Guest::Base.new(ui) }

  before :each do
    env[:vm] = vm
    env[:ui] = ui

    vm.stub(:config).and_return config

    app.stub(:call)

  end

  subject {Vagrant::HostGateway::Enhance.new(app, env) }
  describe '#call' do
    shared_examples "chained hostgateway enhance middleware" do
      it "calls the next middleware" do
        app.should_receive(:call).with(env)

        subject.call(env)
      end
    end
    context "for supported host and guest system" do
      context "with snat on network interface" do
        before :each do
          env[:host] = debian
          env[:vm].stub(:guest).and_return(debian_g)
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
  end
end
