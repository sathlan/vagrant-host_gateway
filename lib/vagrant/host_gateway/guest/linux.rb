require 'log4r'

module Vagrant
  module HostGateway
    class Guest
      module Linux

        def set_gateway(ip_gw)
          @vm.channel.sudo("ip route change default via #{ip_gw}")
        end

        def configure_network(networks)
          nets = []
          networks.each do |network|
            if network[:create_only]
              unless vm.channel.sudo("ip -o address show | grep -q \"#{Regexp.quote(network[:ip])}/#{network_to_cidr(network[:netmask])}\"",
                                     {:error_check => false})
                nets << network
              end
            end
            super(nets)
          end
        end

      end
    end
  end
end
