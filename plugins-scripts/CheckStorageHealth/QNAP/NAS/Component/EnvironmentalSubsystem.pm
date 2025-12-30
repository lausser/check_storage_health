package CheckStorageHealth::QNAP::NAS::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->init_subsystems([
      ["fan_subsystem", "CheckStorageHealth::QNAP::NAS::Component::FanSubsystem"],
      ["temperature_subsystem", "CheckStorageHealth::QNAP::NAS::Component::TemperatureSubsystem"],
      ["disk_subsystem", "CheckStorageHealth::QNAP::NAS::Component::DiskSubsystem"],
      ["raid_subsystem", "CheckStorageHealth::QNAP::NAS::Component::RaidSubsystem"],
  ]);
}



sub check {
  my ($self) = @_;
  $self->check_subsystems();
}

sub dump {
  my ($self) = @_;
  $self->dump_subsystems();
  $self->SUPER::dump();
}

