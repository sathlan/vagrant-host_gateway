require 'digest/md5'

module Vagrant
  module HostGateway
    class Host
      module Linux
        def enable_forwarding
          @logger.info("Seting up forwarding")
          system('sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1')
        end

        def setup_nat(traffic, nic = false)
          @logger.info("Seting up nat")
          interface = case nic
                      when /.+/ then nic
                      when false then false
                      else get_default_gw_nic
                      end
          if interface
            command = "sudo iptables -t nat -I POSTROUTING 1 -o #{interface} -s #{traffic} -j MASQUERADE -m comment --comment 'Done by Vagrant'"
            id = Digest::MD5.hexdigest(command)
            unless system("sudo iptables -t nat -L POSTROUTING -nvx | egrep -q #{id} ")
              system("sudo iptables -t nat -I POSTROUTING 1 -o #{interface} -s #{traffic} -j MASQUERADE -m comment --comment 'Done by Vagrant: #{id}'")
            end
          end
          interface
        end

        def get_default_gw_nic
          @logger.info("Finding the nic of the default gateway")
          nic = `ip route show | awk '/default/{print $NF}'`.strip
          raise InvalidInterface unless check_nic(nic)
          nic
        end

        private
        def check_nic(nic)
          system(%Q\ip address show dev #{nic} >/dev/null 2>&1\)
        end

      end
    end
  end
end
