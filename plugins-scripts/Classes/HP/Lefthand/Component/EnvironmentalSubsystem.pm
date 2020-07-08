package Classes::HP::Lefthand::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LEFTHAND-NETWORKS-NSM-INFO-MIB", qw(infoModel
      infoHostname infoSerialNumber infoProductName infoHardwareDescription
      infoSoftwareType infoSoftwareVersion infoBIOSVersion
  ));
  $self->init_subsystems([
      ["cache_subsystem", "Classes::HP::Lefthand::Component::CacheSubsystem"],
      ["power_subsystem", "Classes::HP::Lefthand::Component::PowersupplySubsystem"],
      ["fan_subsystem", "Classes::HP::Lefthand::Component::FanSubsystem"],
      ["temperature_subsystem", "Classes::HP::Lefthand::Component::TemperatureSubsystem"],
      ["disk_subsystem", "Classes::HP::Lefthand::Component::DiskSubsystem"],
      ["raid_subsystem", "Classes::HP::Lefthand::Component::RaidSubsystem"],
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

