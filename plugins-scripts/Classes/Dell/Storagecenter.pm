package Classes::Dell::Storagecenter;
our @ISA = qw(Classes::Dell);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_env_subsystem("Classes::Dell::Storagecenter::Component::EnvironmentalSubsystem");
  } else {
    $self->no_such_mode();
  }
}
