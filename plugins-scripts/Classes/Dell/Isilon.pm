package Classes::Dell::Isilon;
our @ISA = qw(Classes::Dell);
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
  if ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::Dell::Isilon::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_sensor_subsystem("Classes::Dell::Isilon::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::storage::filesystem::free/) {
    $self->analyze_and_check_disk_subsystem("Classes::Dell::Isilon::Component::StorageSubsystem");
  } elsif ($self->mode =~ /device::storage::snapshots/) {
    $self->analyze_and_check_disk_subsystem("Classes::Dell::Isilon::Component::SnapshotSubsystem");
  } elsif ($self->mode =~ /device::storage::quota/) {
    $self->analyze_and_check_disk_subsystem("Classes::Dell::Isilon::Component::QuotaSubsystem");
  } elsif ($self->mode =~ /device::network/) {
    $self->analyze_and_check_disk_subsystem("Classes::Dell::Isilon::Component::NetworkSubsystem");
  } elsif ($self->mode =~ /device::cluster::health/) {
    $self->analyze_and_check_cluster_subsystem("Classes::Dell::Isilon::Component::ClusterSubsystem");
  } else {
    $self->no_such_mode();
  }
}


