package CheckStorageHealth::QNAP::NAS::Component::RaidSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("QTS-MIB", [
    ["raids", "raidTable", "CheckStorageHealth::QNAP::NAS::Component::RaidSubsystem::Raid"],
    ["pool", "storagepoolTable", "CheckStorageHealth::QNAP::NAS::Component::RaidSubsystem::Pool"],
  ]);
}


package CheckStorageHealth::QNAP::NAS::Component::RaidSubsystem::Raid;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "raid %s %s status is %s",
      $self->{raidLevel},
      $self->{raidName}, $self->{raidStatus});
  if (lc $self->{raidStatus} ne "ready") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}


package CheckStorageHealth::QNAP::NAS::Component::RaidSubsystem::Pool;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{usage} = 100 *
      ($self->{storagepoolCapacity} - $self->{storagepoolFreeSize}) /
      $self->{storagepoolCapacity};

}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "pool %s status is %s",
      $self->{storagepoolID},
      $self->{storagepoolStatus});
  if (lc $self->{storagepoolStatus} ne "ready") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
  $self->set_thresholds(
      metric => sprintf("pool_%s_usage", $self->{storagepoolID}),
      warning => 85,
      critical => 95,
  );
  $self->add_perfdata(
      label => sprintf("pool_%s_usage", $self->{storagepoolID}),
      uom => "%",
      value => $self->{usage}
  );
}


