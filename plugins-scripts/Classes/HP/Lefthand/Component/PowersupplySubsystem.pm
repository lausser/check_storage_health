package Classes::HP::Lefthand::Component::PowersupplySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-INFO-MIB", [
    ["powers", "infoPowerSupplyTable", "Classes::HP::Lefthand::Component::PowersupplySubsystem::Powersupply"],
  ]);
}


package Classes::HP::Lefthand::Component::PowersupplySubsystem::Powersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "powersupply %s has status %s,%s",
      $self->{infoPowerSupplyName}, $self->{infoPowerSupplyState},
      $self->{infoPowerSupplyStatus});
  if ($self->{infoPowerSupplyStatus} ne "pass") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}

