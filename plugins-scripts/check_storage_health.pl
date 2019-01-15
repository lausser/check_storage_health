#! /usr/bin/perl

use strict;
no warnings qw(once);

if ( ! grep /BEGIN/, keys %Monitoring::GLPlugin::) {
  eval {
    require Monitoring::GLPlugin;
    require Monitoring::GLPlugin::SNMP;
  };
  if ($@) {
    printf "UNKNOWN - module Monitoring::GLPlugin was not found. Either build a standalone version of this plugin or set PERL5LIB\n";
    printf "%s\n", $@;
    exit 3;
  }
}

my $lugin = Classes::Device->new();

my $plugin = Classes::Device->new(
    shortname => '',
    usage => 'Usage: %s [ -v|--verbose ] [ -t <timeout> ] '.
        '--mode <what-to-do> '.
        '--hostname <network-component> --community <snmp-community>'.
        '  ...]',
    version => '$Revision: #PACKAGE_VERSION# $',
    blurb => 'This plugin checks storage systems from various manufacturers ',
    url => 'http://labs.consol.de/nagios/check_storage_health',
    timeout => 60,
);

$plugin->add_mode(
    internal => 'device::hardware::load',
    spec => 'cpu-load',
    alias => undef,
    help => 'Check the CPU load of the device',
);
$plugin->add_mode(
    internal => 'device::hardware::memory',
    spec => 'memory-usage',
    alias => undef,
    help => 'Check the memory usage of the device',
);
$plugin->add_mode(
    internal => 'device::hardware::health',
    spec => 'hardware-health',
    alias => undef,
    help => 'Check the status of environmental equipment (fans, temperatures, power)',
);
$plugin->add_mode(
    internal => 'device::sensor::status',
    spec => 'sensor-status',
    alias => undef,
    help => 'Check the status of the sensors',
);
$plugin->add_mode(
    internal => 'device::storage::qr::free',
    spec => 'qr-free',
    alias => undef,
    help => 'Check the free space in a qtree',
);
$plugin->add_mode(
    internal => 'device::storage::qr::list',
    spec => 'list-qtrees',
    alias => undef,
    help => 'List the qtrees',
);
$plugin->add_mode(
    internal => 'device::hardware::raid::list',
    spec => 'list-raids',
    alias => undef,
    help => 'List the raids',
);
$plugin->add_mode(
    internal => 'device::hardware::plex::list',
    spec => 'list-plexes',
    alias => undef,
    help => 'List the plexes',
);
$plugin->add_mode(
    internal => 'device::hardware::volume::list',
    spec => 'list-volumes',
    alias => undef,
    help => 'List the volumes',
);
$plugin->add_mode(
    internal => 'device::hardware::aggregate::list',
    spec => 'list-aggregates',
    alias => undef,
    help => 'List the aggregates',
);
$plugin->add_arg(
    spec => 'subsystem=s',
    help => "--subsystem
 Select a specific hardware subsystem",
    required => 0,
    default => undef,
);

$plugin->add_snmp_modes();
$plugin->add_snmp_args();
$plugin->add_default_args();

$plugin->getopts();
$plugin->classify();
$plugin->validate_args();

if (! $plugin->check_messages()) {
  $plugin->init();
  if (! $plugin->check_messages()) {
    $plugin->add_ok($plugin->get_summary())
        if $plugin->get_summary();
    $plugin->add_ok($plugin->get_extendedinfo(" "))
        if $plugin->get_extendedinfo();
  }
}
my ($code, $message) = $plugin->opts->multiline ?
    $plugin->check_messages(join => "\n", join_all => ', ') :
    $plugin->check_messages(join => ', ', join_all => ', ');
$message .= sprintf "\n%s\n", $plugin->get_info("\n")
    if $plugin->opts->verbose >= 1;

$plugin->nagios_exit($code, $message);

