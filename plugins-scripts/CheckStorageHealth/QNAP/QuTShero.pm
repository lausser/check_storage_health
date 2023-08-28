package CheckStorageHealth::QNAP::QuTShero;
use parent -norequire, 'CheckStorageHealth::QNAP';
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode eq "device::hardware::health") {
    $self->analyze_and_check_sensor_subsystem("CheckStorageHealth::QNAP::QuTShero::Component::EnvironmentalSubsystem");
    $self->reduce_messages_short("hardware working fine");
  } elsif ($self->mode =~ /device::storage::filesystem::free/) {
    $self->analyze_and_check_folder_subsystem("CheckStorageHealth::QNAP::QuTShero::Component::StorageSubsystem");
    $self->analyze_and_check_disk_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem");
  } elsif ($self->mode eq "device::hardware::load") {
    #$self->analyze_and_check_hrcpu_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::CpuSubsystem");
    $self->analyze_and_check_cpu_subsystem("CheckStorageHealth::QNAP::QuTShero::Component::CpuSubsystem");
  } elsif ($self->mode eq "device::hardware::memory") {
    #$self->analyze_and_check_hrmem_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::MemSubsystem");
    $self->analyze_and_check_mem_subsystem("CheckStorageHealth::QNAP::QuTShero::Component::MemSubsystem");
  } else {
    $self->no_such_mode();
  }
}

