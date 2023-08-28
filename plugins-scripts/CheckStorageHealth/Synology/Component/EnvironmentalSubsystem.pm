package CheckStorageHealth::Synology::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("SYNOLOGY-SYSTEM-MIB", qw(systemStatus
      temperature powerStatus systemFanStatus cpuFanStatus modelName
      serialNumber version upgradeAvailable));
  $self->init_subsystems([
      ["disk_subsystem", "CheckStorageHealth::Synology::Component::DiskSubsystem"],
      ["raid_subsystem", "CheckStorageHealth::Synology::Component::RaidSubsystem"],
  ]);
}



sub check {
  my ($self) = @_;
  foreach my $status (qw(systemStatus powerStatus systemFanStatus cpuFanStatus)) {
    if ($self->{$status} eq "Normal") {
      $self->add_ok(sprintf "%s is %s", $status, $self->{$status});
    } else {
      $self->add_critical(sprintf "%s is %s", $status, $self->{$status});
    }
  }
  $self->add_perfdata(
    label => 'temperature',
    value => $self->{temperature},
    warning => 45,
    critical => 60,
  );
  $self->check_subsystems();
}

sub dump {
  my ($self) = @_;
  $self->dump_subsystems();
  $self->SUPER::dump();
}

