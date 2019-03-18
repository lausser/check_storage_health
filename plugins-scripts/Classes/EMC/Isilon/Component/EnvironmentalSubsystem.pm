package Classes::EMC::Isilon::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->{node_subsystem} =
      Classes::EMC::Isilon::Component::NodeSubsystem->new()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "node_subsystem");
  $self->{disk_subsystem} =
      Classes::EMC::Isilon::Component::DiskSubsystem->new()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "disk_subsystem");
  $self->{temperature_subsystem} =
      Classes::EMC::Isilon::Component::TemperatureSubsystem->new()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "temperature_subsystem");
  $self->{fan_subsystem} =
      Classes::EMC::Isilon::Component::FanSubsystem->new()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "fan_subsystem");
  $self->{powersensor_subsystem} =
      Classes::EMC::Isilon::Component::PowersensorSubsystem->new()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "powersensor_subsystem");
}

sub check {
  my ($self) = @_;
  $self->{node_subsystem}->check()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "node_subsystem");
  $self->{disk_subsystem}->check()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "disk_subsystem");
  $self->{temperature_subsystem}->check()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "temperature_subsystem");
  $self->{fan_subsystem}->check()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "fan_subsystem");
  $self->{powersensor_subsystem}->check()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "powersensor_subsystem");
  $self->reduce_messages_short("environmental hardware working fine");
}

sub dump {
  my ($self) = @_;
  $self->{node_subsystem}->dump()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "node_subsystem");
  $self->{disk_subsystem}->dump()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "disk_subsystem");
  $self->{temperature_subsystem}->dump()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "temperature_subsystem");
  $self->{fan_subsystem}->dump()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "fan_subsystem");
  $self->{powersensor_subsystem}->dump()
      if (! $self->opts->subsystem || $self->opts->subsystem eq "powersensor_subsystem");
}

