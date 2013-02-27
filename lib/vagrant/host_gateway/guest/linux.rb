require 'log4r'

module Vagrant
  module HostGateway
    class Guest
      module Linux
        include Utils

        def set_gateway(ip_gw)
          @vm.channel.sudo("ip route change default via #{ip_gw}")
        end

        def want_create_only_for(args)
          @want_create_only ||= {}
          @want_create_only.merge!(args||{})
        end

        def want_create_only(ip)
          @want_create_only ||= {}
          @want_create_only[ip] ||= false
        end

        def configure_networks(networks)
          @logger.info "Checking if we want to reconfigure host-only interface"
          # interfaces that will be configured and restarted
          nets_to_configure = []
          # interface whose configuration must be put back into the
          # configuration file, but without the need to restart them.
          nets_to_keep      = []

          networks.each do |network|

            if want_create_only(network[:ip]) and network[:type] == :static
              cidr_ip = "#{Regexp.quote(network[:ip])}/#{network_to_cidr(network[:netmask])}"
              nic     = "eth#{network[:interface]}"
              @logger.info "Checking if the ip \"#{cidr_ip}\" is already configured on #{nic}"
              if vm.channel.sudo("ip -o address show dev #{nic}| egrep -q \"#{cidr_ip}\"",
                                 {:error_check => false}) != 0
                @logger.info "IP configuration not found.  Adding it to the configuration"
                nets_to_configure << network
              else
                @logger.info "IP configuration found."
                nets_to_keep << network
              end
            else
              nets_to_configure << network
            end

          end

          # all the interfaces configuration will be destroyed by the
          # parent method, so we painfully add the relevent one if we
          # call it.  The net expected result is to have all the
          # interfaces configured inside the interfaces file and the
          # ifup/ifdown done only for the missing one.
          unless nets_to_configure.empty?
            super(nets_to_configure)
            entries = []
            nets_to_keep.each do |network|
              entry = ::Vagrant::Util::TemplateRenderer.render("guests/debian/network_static",
                                                               :options => network)
              entries << entry
            end
            unless nets_to_keep.empty?
              temp = Tempfile.new('vagrant-keeper')
              temp.binmode
              temp.write(entries.join("\n"))
              temp.close
              vm.channel.upload(temp.path, "/tmp/vagrant-network-entry-keep")
              vm.channel.sudo("cat /tmp/vagrant-network-entry-keep >> /etc/network/interfaces" )
            end
          end
        end

      end
    end
  end
end
