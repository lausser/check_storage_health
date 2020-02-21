package Classes::Dell::Datadomain;
use parent -norequire, 'Classes::Dell';
use strict;

sub init {
  my ($self) = @_;
  if ($self->mode eq "device::hardware::health") {
    $self->analyze_and_check_sensor_subsystem("Classes::Dell::Datadomain::Component::EnvironmentalSubsystem");
    $self->reduce_messages("hardware working fine");
  } elsif ($self->mode eq "device::hardware::load") {
    # gibt nur avg und max, abfrage dauert ewig
    #$self->analyze_and_check_sensor_subsystem("Classes::Dell::Datadomain::Component::CpuSubsystem");
    # gibt sys/user/idle/wait..., geht schnell
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode eq "device::hardware::memory") {
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } else {
    $self->no_such_mode();
  }
}

