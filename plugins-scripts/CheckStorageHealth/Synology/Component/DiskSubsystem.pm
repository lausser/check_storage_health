package CheckStorageHealth::Synology::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("SYNOLOGY-DISK-MIB", [
    ["disks", "diskTable", "CheckStorageHealth::Synology::Component::DiskSubsystem::Disk"],
  ]);
}


package CheckStorageHealth::Synology::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s disk %s status is %s",
      $self->{diskType}, $self->{diskID},
      $self->{diskStatus});
  if ($self->{diskStatus} eq "Normal") {
    $self->add_ok();
  } elsif ($self->{diskStatus} eq "Crashed") {
    $self->add_critical();
  } elsif ($self->{diskStatus} eq "SystemPartitionFailed") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
  my $label = sprintf "%s_temperature", $self->{diskID};
  $label =~ s/\s+/_/g;
  $self->add_perfdata(
    label => $label,
    value => $self->{diskTemperature},
  );
}
