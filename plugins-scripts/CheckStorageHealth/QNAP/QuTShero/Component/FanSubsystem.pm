package CheckStorageHealth::QNAP::QuTShero::Component::FanSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("QTS-HERO-MIB", [
    ["fans", "systemFanTable", "CheckStorageHealth::QNAP::QuTShero::Component::FanSubsystem::Fan"],
  ]);
}


package CheckStorageHealth::QNAP::QuTShero::Component::FanSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s status has %.2frpm",
      $self->{sysFanDescr}, $self->{sysFanSpeed});
  $self->add_ok();
  $self->add_perfdata(
      label => sprintf("fan_%s_rpm", $self->{sysFanDescr}),
      value => $self->{sysFanSpeed},
  );
}

