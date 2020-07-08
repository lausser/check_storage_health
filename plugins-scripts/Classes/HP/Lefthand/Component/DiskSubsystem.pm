package Classes::HP::Lefthand::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-STORAGE-MIB", [
    ["disks", "storageDeviceTable", "Classes::HP::Lefthand::Component::DiskSubsystem::Disk"],
  ]);
}


package Classes::HP::Lefthand::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s status is %s,%s (smart: %s,%s, temperature: %sC,%s)",
      $self->{storageDeviceName}, $self->{storageDeviceState},
      $self->{storageDeviceStatus},
      $self->{storageDeviceSmartHealth},
      $self->{storageDeviceSmartHealthStatus},
      $self->{storageDeviceTemperature},
      $self->{storageDeviceTemperatureStatus});
  if ($self->{storageDeviceStatus} ne "pass" ||
      $self->{storageDeviceSmartHealthStatus} ne "pass" ||
      $self->{storageDeviceTemperatureStatus} ne "pass") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}
