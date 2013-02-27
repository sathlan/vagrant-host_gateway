module Vagrant
  module HostGateway
    class Host
      module Linux
        def enable_forwarding
          system('sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1')
        end

        def setup_nat(nic, net)
          unless system(%Q\ip address show dev #{nic} >/dev/null 2>&1\)
            raise InvalidInterface
          end
          unless system(%Q/sudo iptables -t nat -L POSTROUTING -nvx | egrep 'MASQUERADE.*#{nic}.*#{net}'/)
            system("sudo iptables -t nat -I POSTROUTING 1 -o #{nic} -s #{net} -j MASQUERADE -m comment --comment 'Done by Vagrant'")
          end
        end
      end
    end
  end
end
