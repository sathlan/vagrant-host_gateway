module Vagrant
  module HostGateway
    class Config < Vagrant::Config::Base
      attr_accessor :gateway

      def validate(env, errors)
        begin
          ip = IPAddress gateway
        rescue
          errors.add(I18n.t(:invalidip, "vagrant.hostgateway", :ip => gateway))
        end
      end

    end
  end
end
