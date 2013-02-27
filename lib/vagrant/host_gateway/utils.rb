module Vagrant
  module HostGateway
    module Utils
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
