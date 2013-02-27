module Vagrant
  module HostGateway
    class Middleware
      include Utils

      def initialize(app, env)
        @app          = app
        @env          = env
      end

      def call(env)

        @app.call(env)

        # All the interfaces are up, we can set the gateway.
        gateway = env[:vm].config.host.gateway

        if !gateway.nil?
          env[:ui].info "Setting gateway to #{gateway}"
          env[:vm].guest.set_gateway(gateway)
        end

      end

    end
  end
end
