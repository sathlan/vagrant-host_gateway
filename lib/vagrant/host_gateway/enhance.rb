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

        env[:vm].config.vm.networks.each do |type, args|
          if type == :hostonly
            ip = args[0]
            options = { :nat => false }.merge(args[1] || {})
            if nic = options[:nat]
              env[:ui].info "Enabling forwarding on host."
              env[:host].enable_forwarding
              traffic = "#{ip}/#{Middleware.network_to_cidr(options[:netmask])}"
              env[:ui].info "Setting up SNAT on #{nic} catching traffic from #{traffic}"
              env[:host].setup_nat(nic, traffic)
            end
            # record if the user want to setup the nic if they are already set up
            env[:vm].guest.want_create_only_for(ip => true) if options[:create_only]
          end
        end
      end
    end
  end
end
