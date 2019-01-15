package Classes::NetApp::Filer;
our @ISA = qw(Classes::NetApp);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::sensor::status/) {
    $self->analyze_and_check_sensor_subsystem("Classes::NetApp::Filer::Component::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::NetApp::Filer::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::NetApp::Filer::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_sensor_subsystem("Classes::NetApp::Filer::SensorSubsystem");
  } elsif ($self->mode =~ /device::hardware::raid::list/) {
    $self->analyze_and_check_disk_subsystem("Classes::NetApp::Filer::Component::DiskSubsystem");
  } elsif ($self->mode =~ /device::hardware::plex::list/) {
    $self->analyze_and_check_plex_subsystem("Classes::NetApp::Filer::Component::PlexSubsystem");
  } elsif ($self->mode =~ /device::hardware::volume::list/) {
    $self->analyze_and_check_volume_subsystem("Classes::NetApp::Filer::Component::VolumeSubsystem");
  } elsif ($self->mode =~ /device::hardware::aggregate::list/) {
    $self->analyze_and_check_aggregate_subsystem("Classes::NetApp::Filer::Component::AggregateSubsystem");
  } elsif ($self->mode =~ /device::storage::gr/) {
    $self->analyze_and_check_qr_subsystem();
  } else {
    $self->no_such_mode();
  }
}

sub model_serial {
  my $self = shift;
  return sprintf '%s %s, FW:%s, Serial:%s',
      $self->name_of_oid('NETAPP-MIB', $self->{sysobjectid}),
      $self->get_snmp_object('NETAPP-MIB', 'productModel'),
      $self->get_snmp_object('NETAPP-MIB', 'productFirmwareVersion'),
      $self->get_snmp_object('NETAPP-MIB', 'productSerialNum');
}

package Classes::NetApp::ClusteredFiler;
our @ISA = qw(Classes::NetApp::Filer);

package Classes::NetApp::NetCache;
our @ISA = qw(Classes::NetApp::Filer);


