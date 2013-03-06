require 'digest/md5'

module Vagrant
  module HostGateway
    class Host
      module Linux
        def enable_forwarding
          system('sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1')
        end

        def setup_nat(nic, traffic)
          unless system(%Q\ip address show dev #{nic} >/dev/null 2>&1\)
            raise InvalidInterface
          end
          command = "sudo iptables -t nat -I POSTROUTING 1 -o #{nic} -s #{traffic} -j MASQUERADE -m comment --comment 'Done by Vagrant'"
          id = Digest::MD5.hexdigest(command)
          unless system("sudo iptables -t nat -L POSTROUTING -nvx | egrep -q #{id} ")
            system("sudo iptables -t nat -I POSTROUTING 1 -o #{nic} -s #{traffic} -j MASQUERADE -m comment --comment 'Done by Vagrant: #{id}'")
          end
        end
      end
    end
  end
end
