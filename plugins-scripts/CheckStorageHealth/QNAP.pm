package CheckStorageHealth::QNAP;
our @ISA = qw(CheckStorageHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->implements_mib("QTS-HERO-MIB")) {
    # high end mit zfs
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'QTS-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'QTS-HERO-MIB'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'QTS-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'QTS-HERO-MIB'};
    $self->rebless("CheckStorageHealth::QNAP::QuTShero");
  } elsif ($self->implements_mib("QTS-QTS-MIB")) {
    # consumer und middle-segment
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'QTS-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'QTS-QTS-MIB'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'QTS-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'QTS-QTS-MIB'};
    $self->rebless("CheckStorageHealth::QNAP::QTS");
  } elsif ($self->implements_mib("NAS-MIB")) {
    # alte modelle. kostet was
  }
  if (ref($self) ne "CheckStorageHealth::QNAP") {
    $self->init();
  }
}

