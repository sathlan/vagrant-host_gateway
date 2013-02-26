require 'log4r'

module Vagrant
  module HostGateway
    class Host
      class Unsupported < Errors::VagrantError
        error_key(:unsupported, "vagrant.hostgateway.host")
      end

      class InvalidInterface < Errors::VagrantError
        error_key(:invalidinterface, "vagrant.hostgateway.host")
      end

      SUPPORTED = %w(Linux BSD)
      SUPPORTED.each do |os|
        autoload :"#{os.capitalize}", "vagrant/host_gateway/host/#{os.downcase}"
      end

      attr_reader :host

      def initialize (env)
        @host       = env[:host]
        @logger = Log4r::Logger.new("vagrant::hostgateway::host")
      end

      def host_classes
        @host_classes ||= @host.class.ancestors.map {|c| c.to_s }.grep(/Hosts/).
          map {|s| s.sub(/Vagrant::Hosts::/,'')}
      end

      def host_class
        @host_class ||= (host_classes & SUPPORTED).first
      end

      def is_supported?
        !host_class.nil?
      end

      def enhance!
        if is_supported?
          host.extend Vagrant::HostGateway::Host.const_get host_class.capitalize
        else
          raise Unsupported, { :os => host_classes }
        end
      end
    end
  end
end

