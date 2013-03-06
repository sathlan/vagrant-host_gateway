module Vagrant
  module HostGateway
    class Host
      module Bsd

        def enable_forwarding
          @logger.info("Seting up forwarding")
          system('sudo sysctl -w net.inet.ip.forwarding=1 >/dev/null 2>&1')
        end
        # some effort should be done to be able to distinguish between
        # pf firewall (freebsd, openbsd) and ipfw firewall (freebsd,
        # darwin) to enable darwin support.
        def setup_nat(nic, traffic)
          @logger.info("Seting up nat")
          unless system(%Q|ifconfig #{nic} >/dev/null 2>&1|)
            raise InvalidInterface
          end
          # reload rules to take into account new interfaces.
          system('sudo /etc/rc.d/pf reload >/dev/null 2>&1')
          # add nat if it's not there
          nat = %Q|#{Regexp.quote("nat on #{nic} from #{traffic} to any -> (#{nic}:0)")}|
          @logger.info("Looking for \"#{nat}\" in the pf configuration.")
          unless system(%Q\sudo pfctl -s nat 2>/dev/null | egrep -q '#{nat}'\)
            @logger.info("Not found.  Apply it.")
            system(%Q{sudo pfctl -s nat 2>/dev/null | bash -c 'cat - <(echo "nat on #{nic} from #{traffic} to any -> (#{nic}:0)")' | sudo pfctl -m -N -f - >/dev/null 2>&1 })
          end
        end
      end
    end
  end
end
