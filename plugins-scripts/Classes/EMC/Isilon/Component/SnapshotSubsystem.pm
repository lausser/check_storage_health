package Classes::EMC::Isilon::Component::SnapshotSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(20);
  $self->get_snmp_tables("ISILON-MIB", [
      ["snapshots", "snapshotTable", "Classes::EMC::Isilon::Component::SnapshotSubsystem::Snapshot",]
  ]);
}


package Classes::EMC::Isilon::Component::SnapshotSubsystem::Snapshot;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{snapshotAgeDays} = (time - $self->{snapshotCreated}) / (3600*24);
}

sub check {
  my ($self) = @_;
  if ($self->mode eq "device::storage::snapshots::age") {
    $self->add_info(sprintf "snapshot %s is %.1f days old",
        $self->{snapshotName}, $self->{snapshotAgeDays});
    $self->set_thresholds(
        metric => $self->{snapshotName},
        warning => 30,
        critical => 60,
    );
    if (! $self->{snapshotExpires}) {
      $self->add_message($self->check_thresholds(
        metric => $self->{snapshotName},
        value => $self->{snapshotAgeDays},
      ));
    } else {
      $self->add_ok();
    }
  }
}
