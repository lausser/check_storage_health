package CheckStorageHealth::Dell::Storagecenter::Component::AlertSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(5);
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["alerts", "scAlertTable", "CheckStorageHealth::Dell::Storagecenter::Component::AlertSubsystem::Alert"],
  ]);
  $self->bulk_baeh_reset();
}


package CheckStorageHealth::Dell::Storagecenter::Component::AlertSubsystem::Alert;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s %s",
      $self->{scAlertType}, $self->{scAlertMessage});
  if ($self->{scAlertStatus} eq "inform") {
    $self->add_ok();
  } elsif ($self->{scAlertAcknowledged} eq "false") {
    if ($self->{scAlertType} eq "alert") {
      $self->add_critical();
    } else {
      $self->add_warning();
    }
  } else {
    $self->add_ok();
  }
}

sub internal_content {
  my ($self) = @_;
  return $self->{scAlertMessage};
}
