module Vagrant
  module HostGateway
    class Host
      module Freebsd

        def enable_forwarding
          @logger.info("Seting up forwarding")
          system('sysctl -w net.inet.ip.forwarding=1')
        end
        def setup_nat(nic, net)
          @logger.info("Seting up nat")
          unless system(%Q/ifconfig #{nic}/)
            raise InvalidInterface
          end
          unless system(%Q/sudo pfctl -s nat | grep -q '#{Regexp.quote("nat on #{nic} from #{net} to any -> (#{nic}:0)")}'/)
            system(%Q{sudo pfctl -s nat 2>/dev/null | bash -c 'cat - <(echo "nat on #{nic} from #{net} to any -> (#{nic}:0)")' | sudo pfctl -m -N -f -})
          end
        end
      end
    end
  end
end
