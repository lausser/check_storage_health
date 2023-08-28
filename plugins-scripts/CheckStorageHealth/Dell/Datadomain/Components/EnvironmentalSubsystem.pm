package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->init_subsystems([
      ["temperature_subsystem", "CheckStorageHealth::Dell::Datadomain::Component::TemperatureSubsystem"],
      ["fan_subsystem", "CheckStorageHealth::Dell::Datadomain::Component::FanSubsystem"],
      ["powersupply_subsystem", "CheckStorageHealth::Dell::Datadomain::Component::PowersupplySubsystem"],
      ["disk_subsystem", "CheckStorageHealth::Dell::Datadomain::Component::DiskSubsystem"],

      ["alert_subsystem", "CheckStorageHealth::Dell::Datadomain::Component::AlertSubsystem"],
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

