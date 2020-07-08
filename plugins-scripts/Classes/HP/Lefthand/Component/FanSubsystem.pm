package Classes::HP::Lefthand::Component::FanSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-INFO-MIB", [
    ["fans", "infoFanTable", "Classes::HP::Lefthand::Component::FanSubsystem::Fan"],
  ]);
}


package Classes::HP::Lefthand::Component::FanSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "fan %s status is %s,%s",
      $self->{infoFanName}, $self->{infoFanState}, $self->{infoFanStatus});
  if ($self->{infoFanStatus} ne "pass") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}

