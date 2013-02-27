module Vagrant
  module HostGateway
    class Enhance
      def initialize(app, env)
        @app          = app
        @env          = env
      end

      def call(env)

        @app.call(env)

        # The guest is running.  We now it new subtype and enhance
        # with the new functions.
        Vagrant::HostGateway::Host.new(env).enhance!
        Vagrant::HostGateway::Guest.new(env).enhance!

      end
    end
  end
end
