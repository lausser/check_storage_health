package CheckStorageHealth::QNAP::QuTShero::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->init_subsystems([
#      ["cache_subsystem", "CheckStorageHealth::QNAP::QuTShero::Component::CacheSubsystem"],
      ["powersupply_subsystem", "CheckStorageHealth::QNAP::QuTShero::Component::PowersupplySubsystem"],
      ["fan_subsystem", "CheckStorageHealth::QNAP::QuTShero::Component::FanSubsystem"],
      ["temperature_subsystem", "CheckStorageHealth::QNAP::QuTShero::Component::TemperatureSubsystem"],
      ["disk_subsystem", "CheckStorageHealth::QNAP::QuTShero::Component::DiskSubsystem"],
      ["raid_subsystem", "CheckStorageHealth::QNAP::QuTShero::Component::RaidSubsystem"],
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

