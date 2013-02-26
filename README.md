# Vagrant::HostGateway

This vagrant plugin add some features to the *host-only* support in
vagrant.

The features added are:

 1. possibility to define the gateway in the guest to be different from
 the one given by the dhcp process on the NAT interface;
 2. possibility to define a the hostonly network as traffic to be
 natted on the host;
 3. enable forwarding on the host;
 4. can prevent vagrant from restarting the hostonly associated
 interface in the guest.

Those features enable a guest to have its traffic routed through a
*hostonly* interface instead of the default NAT interface.  With the
source natting done on the given host interface.  With forwarding
activated, this enables the guest to access the internet through the
host-only adapter.  One very visible side effect is that the ping
works.

The last point (4.) assumes that one doesn't want vagrant to mess up
with the interface configuration (like doing ifdown/ifup) if the
interface is already configured, at each reboot.

## Installation

Add this line to your application's Gemfile:

    gem 'vagrant-host_gateway'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vagrant-host_gateway

## Usage

Everything takes place in the Vagrantfile.

### define the gateway

In the vagrant configuration, you can add:

    config.vm.gateway = <ip>

### NAT

You can define natting by adding

    :nat => <host_ifname>

to the *network* configuration.

For instance:

    config.vm.network   :hostonly, '198.51.100.35', :netmask => '255.255.255.224', :nat => 'eth0'

This will source nat the traffic from 198.51.100.32/27, going to the
host eth0 interface (which should be the host's default gateway) to
the eth0 associated ip.

The forwarding will be activated on the host for it to route the
packets.

The net result is that, from the guest, the internet will by available.

### prevent ifdown/ifup

By default, vagrant will recreate all the host-only interface.  Adding

    :create_only => true

to the network configuration, will not do the ifdown/ifup business if
the interface is already up with the proper ip configuration.

Ex:

    config.vm.network   :hostonly, '198.51.100.35', :netmask => '255.255.255.224', :create_only => true

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
