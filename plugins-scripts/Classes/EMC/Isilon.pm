package Classes::EMC::Isilon;
our @ISA = qw(Classes::EMC);
use strict;

sub init {
  my $self = shift;
  if ($self->{productname} =~ /OneFS v8/) {
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ISILON-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ISILON-MIB::201608050000Z'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ISILON-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ISILON-MIB::201608050000Z'};
  } else {
    $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ISILON-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'ISILON-MIB::201608050000Z'};
    $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ISILON-MIB'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'ISILON-MIB::201608050000Z'};
  }
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::EMC::Isilon::Component::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::EMC::Isilon::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::EMC::Isilon::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_sensor_subsystem("Classes::EMC::Isilon::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::raid::list/) {
    $self->analyze_and_check_disk_subsystem("Classes::EMC::Isilon::Component::DiskSubsystem");
  } elsif ($self->mode =~ /device::hardware::plex::list/) {
    $self->analyze_and_check_plex_subsystem("Classes::EMC::Isilon::Component::PlexSubsystem");
  } elsif ($self->mode =~ /device::hardware::volume::list/) {
    $self->analyze_and_check_volume_subsystem("Classes::EMC::Isilon::Component::VolumeSubsystem");
  } elsif ($self->mode =~ /device::hardware::aggregate::list/) {
    $self->analyze_and_check_aggregate_subsystem("Classes::EMC::Isilon::Component::AggregateSubsystem");
  } elsif ($self->mode =~ /device::storage::gr/) {
    $self->analyze_and_check_qr_subsystem();
  } else {
    $self->no_such_mode();
  }
}

sub xxxmodel_serial {
  my $self = shift;
  return sprintf '%s %s, FW:%s, Serial:%s',
      $self->name_of_oid('NETAPP-MIB', $self->{sysobjectid}),
      $self->get_snmp_object('NETAPP-MIB', 'productModel'),
      $self->get_snmp_object('NETAPP-MIB', 'productFirmwareVersion'),
      $self->get_snmp_object('NETAPP-MIB', 'productSerialNum');
}

package Classes::EMC::ClusteredIsilon;
our @ISA = qw(Classes::EMC::Isilon);

package Classes::EMC::NetCache;
our @ISA = qw(Classes::EMC::Isilon);


