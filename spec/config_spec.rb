require 'pry-nav'
require 'spec_helper'

describe Vagrant::HostGateway::Config do
  context "with a valid ip" do
    it "allows a gateway to be set" do
      subject.gateway = '192.168.0.1'
      subject.gateway.should eq '192.168.0.1'
    end
  end

  context "when validating the configuration" do
    before :each do
      @env    = Vagrant::Environment.new
      @errors = Vagrant::Config::ErrorRecorder.new
    end
    it "should catch invalid ip" do
      subject.gateway = '192.258.0.1'
      subject.validate(@env, @errors)

      @errors.errors.should_not be_empty
    end

    it "should catch nonsense ip" do
      subject.gateway = 'foo'
      subject.validate(@env, @errors)

      @errors.errors.should_not be_empty
    end
  end
end
