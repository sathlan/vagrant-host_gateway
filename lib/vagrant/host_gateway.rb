require 'rubygems'
require 'vagrant'
require 'ipaddress'
require 'vagrant/host_gateway/config'
require 'vagrant/host_gateway/middleware'
require 'vagrant/host_gateway/host'
require 'vagrant/host_gateway/guest'

Vagrant.config_keys.register(:hosts) { Vagrant::HostGateway::Config }

Vagrant.actions[:start].insert_before Vagrant::Action::VM::Network, Vagrant::HostGateway::Middleware
Vagrant.actions[:reload].insert_before Vagrant::Action::VM::Network, Vagrant::HostGateway::Middleware

## Default I18n to load the en locale
I18n.load_path << File.expand_path("../../templates/locales/en.yml", File.dirname(__FILE__))
