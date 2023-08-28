package CheckStorageHealth::HP::Lefthand::Component::RaidSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("LEFTHAND-NETWORKS-NSM-STORAGE-MIB", qw(
    storageRaidStatus storageRaidState storageRaidMode storageRaidDescription
  ));
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-STORAGE-MIB", [
    ["raids", "storageRaidTable", "CheckStorageHealth::HP::Lefthand::Component::RaidSubsystem::Raid"],
    ["osraids", "storageOsRaidTable", "CheckStorageHealth::HP::Lefthand::Component::RaidSubsystem::OSRaid"],
  ]);
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s status is %s,%s",
      $self->{storageRaidDescription},
      $self->{storageRaidState}, $self->{storageRaidStatus});
  if ($self->{storageRaidStatus} ne "pass") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
  $self->SUPER::check();
}

package CheckStorageHealth::HP::Lefthand::Component::RaidSubsystem::Raid;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s status is %s,%s (sync: %s%%)",
      $self->{storageRaidDeviceName},
      $self->{storageRaidDeviceState}, $self->{storageRaidDeviceStatus},
      $self->{storageRaidRebuildPercent});
  if ($self->{storageRaidDeviceStatus} ne "pass") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}


package CheckStorageHealth::HP::Lefthand::Component::RaidSubsystem::OSRaid;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s status is %s",
      $self->{storageOsRaidName}, 
      $self->{storageOsRaidState});
  if ($self->{storageOsRaidState} ne "Normal") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}

