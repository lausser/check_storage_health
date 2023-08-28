package CheckStorageHealth::Dell::Storagecenter::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["disks", "scDiskTable", "CheckStorageHealth::Dell::Storagecenter::Component::DiskSubsystem::Disk"],
  ]);
}


package CheckStorageHealth::Dell::Storagecenter::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s disk %s status is %s",
      $self->{scDiskIoPortType}, $self->{scDiskNamePosition},
      $self->{scDiskStatus});
  if ($self->{scDiskStatus} eq "degraded") {
    $self->add_warning();
  } elsif ($self->{scDiskHealthy} ne "true") {
    $self->annotate_info("not healthy");
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}
