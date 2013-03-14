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
        def setup_nat(traffic, nic = false)
          @logger.info("Seting up nat")
          interface = case nic
                      when /.+/ then nic
                      when false then false
                      else get_default_gw_nic
                      end

          # reload rules to take into account new interfaces.
          system('sudo /etc/rc.d/pf reload >/dev/null 2>&1')
          if interface
            # add nat if it's not there
            nat = %Q|#{Regexp.quote("nat on #{interface} from #{traffic} to any -> (#{interface}:0)")}|
            @logger.info("Looking for \"#{nat}\" in the pf configuration.")
            unless system(%Q\sudo pfctl -s nat 2>/dev/null | egrep -q '#{nat}'\)
              @logger.info("Not found.  Apply it.")
              system(%Q{sudo pfctl -s nat 2>/dev/null | bash -c 'cat - <(echo "nat on #{interface} from #{traffic} to any -> (#{interface}:0)")' | sudo pfctl -m -N -f - >/dev/null 2>&1 })
            end
          end
          interface
        end

        def get_default_gw_nic
          @logger.info("Finding the nic of the default gateway")
          nic = `netstat -rn | awk '/default/{print $NF}'`.strip
          raise InvalidInterface unless check_nic(nic)
          nic
        end

        private
        def check_nic(nic)
          system(%Q|ifconfig #{nic} >/dev/null 2>&1|)
        end
      end
    end
  end
end
