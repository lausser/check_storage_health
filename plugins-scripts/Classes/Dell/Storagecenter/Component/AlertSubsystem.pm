package Classes::Dell::Storagecenter::Component::AlertSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["alerts", "scAlertTable", "Classes::Dell::Storagecenter::Component::AlertSubsystem::Alert"],
  ]);
}


package Classes::Dell::Storagecenter::Component::AlertSubsystem::Alert;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s %s",
      $self->{scAlertType}, $self->{scAlertMessage});
  if ($self->{scAlertAcknowledged} eq "false") {
    if ($self->{scAlertType} eq "alert") {
      $self->add_critical();
    } else {
      $self->add_warning();
    }
  } else {
    $self->add_ok();
  }
}

