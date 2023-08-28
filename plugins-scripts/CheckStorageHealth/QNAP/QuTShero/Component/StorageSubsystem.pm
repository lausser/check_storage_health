package CheckStorageHealth::QNAP::QuTShero::Component::StorageSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("QTS-MIB", [
    ["sharedfolders", "sharedFolderTable", "CheckStorageHealth::QNAP::QuTShero::Component::StorageSubsystem::SFolder"],
  ]);
}


package CheckStorageHealth::QNAP::QuTShero::Component::StorageSubsystem::SFolder;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{usage} = 100 *
      ($self->{sharedFolderCapacity} - $self->{sharedFolderFreeSize}) /
      $self->{sharedFolderCapacity};
  $self->{free} = 100 - $self->{usage};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "shared folder %s status is %s (%.2f%% free)",
      $self->{sharedFolderName},
      $self->{sharedFolderStatus},
      $self->{free});
  if (lc $self->{sharedFolderStatus} ne "ready") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
  $self->set_thresholds(
      metric => sprintf("sharedfolder_%s_free_pct", $self->{sharedFolderName}),
      warning => "10:",
      critical => "5:",
  );
  $self->add_message($self->check_thresholds(metric => sprintf('sharedfolder_%s_free_pct', $self->{sharedFolderName}),
      value => $self->{free}));
  $self->add_perfdata(
      label => sprintf("sharedfolder_%s_free_pct", $self->{sharedFolderName}),
      uom => "%",
      value => $self->{free}
  );
}


