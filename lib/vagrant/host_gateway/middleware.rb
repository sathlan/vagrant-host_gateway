module Vagrant
  module HostGateway
    class Middleware
      def initialize(app, env)
        @app          = app
        @env          = env
      end

      def call(env)
        Vagrant::HostGateway::Guest.new(@env).enhance!
        Vagrant::HostGateway::Host.new(@env).enhance!

        @app.call(env)

        gateway = env[:vm].config.vm.gateway

        if !gateway.nil?
          @env[:ui].info "Setting gateway to #{gateway}"
          @env[:vm].guest.set_gateway(gateway)
        end

        @env[:vm].config.vm.networks.each do |type, args|
          if type == :hostonly
            ip = args[0]
            options = { :nat => false }.merge(args[1] || {})
            if nic = options[:nat]
              @env[:ui].debug "Enabling forwarding"
              @env[:host].enable_forwarding
              traffic = "#{ip}/#{network_to_cidr(options[:netmask])}"
              @env[:ui].debug "Setting up SNAT on #{nic} catching traffic from #{traffic}"
              @env[:host].setup_nat(nic, traffic)
            end
          end
        end
      end

      def network_to_cidr(network)
        # if allready in cidr /XX format do nothing.
        cidr = network.sub('/', '')
        return cidr unless cidr.index('.')
        cidr = 32
        network.split('.').each do |mask|
          cidr -= power(mask)
        end
        return cidr
      end

      private
      def power(mask)
        8.downto(0).select { |p| 2**p == (256 - mask.to_i) }[0] || 0
      end

    end
  end
end
