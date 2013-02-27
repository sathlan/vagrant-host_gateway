module Vagrant
  module HostGateway
    class Middleware
      def initialize(app, env)
        @app          = app
        @env          = env
      end

      def call(env)

        @app.call(env)

        # All the interfaces are up, we can set the gateway.
        gateway = env[:vm].config.host.gateway

        if !gateway.nil?
          @env[:ui].info "Setting gateway to #{gateway}"
          @env[:vm].guest.set_gateway(gateway)
        end

      end

      def self.network_to_cidr(network)
        # if allready in cidr /XX format do nothing.
        cidr = network.sub('/', '')
        return cidr unless cidr.index('.')
        cidr = 32
        network.split('.').each do |mask|
          cidr -= Middleware.power(mask)
        end
        return cidr
      end

      private
      def self.power(mask)
        8.downto(0).select { |p| 2**p == (256 - mask.to_i) }[0] || 0
      end

    end
  end
end
