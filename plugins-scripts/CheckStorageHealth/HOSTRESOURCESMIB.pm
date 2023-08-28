package CheckStorageHealth::HOSTRESOURCESMIB;
our @ISA = qw(CheckStorageHealth::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::EnvironmentalSubsystem");
    $self->analyze_and_check_environmental_subsystem("CheckStorageHealth::LMSENSORSMIB::Component::EnvironmentalSubsystem");
    if (! $self->check_messages()) {
      $self->reduce_messages("hardware working fine");
    }
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::storage::filesystem/) {
    $self->analyze_and_check_mem_subsystem("CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem");
  } else {
    $self->no_such_mode();
  }
}

