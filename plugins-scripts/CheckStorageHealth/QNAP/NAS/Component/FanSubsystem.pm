package CheckStorageHealth::QNAP::NAS::Component::FanSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("NAS-MIB", [
    ["fans", "systemFanTable", "CheckStorageHealth::QNAP::NAS::Component::FanSubsystem::Fan"],
  ]);
}

package CheckStorageHealth::QNAP::NAS::Component::FanSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;

  return unless defined $self->{sysFanDescr};

  $self->add_info(sprintf "%s status has %.2frpm",
      $self->{sysFanDescr}, $self->{sysFanSpeed});
  $self->add_ok();
  $self->add_perfdata(
      label => sprintf("fan_%s_rpm", $self->{sysFanDescr}),
      value => $self->{sysFanSpeed},
  );
}
