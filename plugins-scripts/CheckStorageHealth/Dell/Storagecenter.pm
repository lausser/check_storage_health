package CheckStorageHealth::Dell::Storagecenter;
our @ISA = qw(CheckStorageHealth::Dell);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("CheckStorageHealth::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("CheckStorageHealth::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_env_subsystem("CheckStorageHealth::Dell::Storagecenter::Component::EnvironmentalSubsystem");
  } else {
    $self->no_such_mode();
  }
}
