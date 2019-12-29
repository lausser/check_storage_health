package Classes::Dell::Isilon::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->init_subsystems([
      ["node_subsystem", "Classes::Dell::Isilon::Component::NodeSubsystem"],
      ["disk_subsystem", "Classes::Dell::Isilon::Component::DiskSubsystem"],
      ["temperature_subsystem", "Classes::Dell::Isilon::Component::TemperatureSubsystem"],
      ["fan_subsystem", "Classes::Dell::Isilon::Component::FanSubsystem"],
      ["powersensor_subsystem", "Classes::Dell::Isilon::Component::PowersensorSubsystem"],
  ]);
}

sub check {
  my ($self) = @_;
  $self->check_subsystems();
  $self->reduce_messages_short("environmental hardware working fine")
      if ! $self->opts->subsystem;
}

sub dump {
  my ($self) = @_;
  $self->dump_subsystems();
}

