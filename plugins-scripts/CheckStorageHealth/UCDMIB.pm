package CheckStorageHealth::UCDMIB;
our @ISA = qw(CheckStorageHealth::Device);
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem("CheckStorageHealth::UCDMIB::Component::DiskSubsystem");
    $self->analyze_and_check_environmental_subsystem("CheckStorageHealth::LMSENSORSMIB::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("CheckStorageHealth::UCDMIB::Component::CpuSubsystem");
    $self->analyze_and_check_load_subsystem("CheckStorageHealth::UCDMIB::Component::LoadSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("CheckStorageHealth::UCDMIB::Component::MemSubsystem");
    $self->analyze_and_check_swap_subsystem("CheckStorageHealth::UCDMIB::Component::SwapSubsystem");
  } else {
    $self->no_such_mode();
  }
}

