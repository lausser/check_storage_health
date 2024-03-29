package CheckStorageHealth::HP::Lefthand;
use parent -norequire, 'CheckStorageHealth::HP';
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode eq "device::hardware::health") {
    $self->analyze_and_check_sensor_subsystem("CheckStorageHealth::HP::Lefthand::Component::EnvironmentalSubsystem");
    $self->reduce_messages("hardware working fine");
  } elsif ($self->mode eq "device::hardware::load") {
    $self->analyze_and_check_cpu_subsystem("CheckStorageHealth::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode eq "device::hardware::memory") {
    $self->analyze_and_check_cpu_subsystem("CheckStorageHealth::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::storage::\w+::free/) {
    $self->analyze_and_check_disk_subsystem("CheckStorageHealth::HP::Lefthand::Component::StorageSubsystem");
  } elsif ($self->mode =~ /device::network/) {
    $self->analyze_and_check_disk_subsystem("CheckStorageHealth::HP::Lefthand::Component::NetworkSubsystem");
  } elsif ($self->mode =~ /device::cluster::health/) {
    $self->analyze_and_check_cluster_subsystem("CheckStorageHealth::HP::Lefthand::Component::ClusterSubsystem");
    $self->reduce_messages("cluster working fine");
  } else {
    $self->no_such_mode();
  }
}


