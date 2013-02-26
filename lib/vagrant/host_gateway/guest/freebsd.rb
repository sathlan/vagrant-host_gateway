require 'log4r'

module Vagrant
  module HostGateway
    class Guest
      module Freebsd
        def initialize
          @logger = Log4r::Logger.new("vagrant::hostgateway::guest::freebsd")
        end

        def set_gateway(ip_gw)
          def set_gateway(ip_gw)
            # raise an error if ip is not an ip
            ip = IPAddress ip_gw
            @vm.channel.sudo("route delete default")
            @vm.channel.sudo("route add default #{ip_gw}")
          end
        end

      end
    end
  end
end
