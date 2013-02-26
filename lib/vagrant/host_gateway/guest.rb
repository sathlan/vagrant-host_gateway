require 'log4r'

module Vagrant
  module HostGateway
    class Guest
      class Unsupported < Errors::VagrantError
        error_key(:unsupported, "vagrant.hostgateway.guest")
      end

      SUPPORTED = %w(Linux Freebsd)
      SUPPORTED.each do |os|
        autoload :"#{os.capitalize}", "vagrant/host_gateway/guest/#{os.downcase}"
      end

      attr_reader :guest, :guest_class

      def initialize (env)
        @guest       = env[:vm].guest
        @logger = Log4r::Logger.new("vagrant::hostgateway::guest")
      end

      def guest_classes
        @guest_classes ||= @guest.class.ancestors.map {|c| c.to_s }.grep(/Guest/).
          map {|s| s.sub(/Vagrant::Guest::/,'')}
      end
      def guest_class
        @guest_class ||= (guest_classes & SUPPORTED).first
      end
      def is_supported?
        !guest_class.nil?
      end

      def enhance!
        if is_supported?
          guest.extend Vagrant::HostGateway::Guest.const_get guest_class.capitalize
        else
          raise Unsupported, { :os => guest_classes }
        end
      end
    end
  end
end

