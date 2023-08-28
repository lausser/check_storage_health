package CheckStorageHealth::QNAP::QuTShero::Component::PowersupplySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("QTS-HERO-MIB", qw(
      sysPowerStatus
      sysUPSStatus
  ));
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "power status is %s",
      $self->{sysPowerStatus});
  if (lc $self->{sysPowerStatus} ne "ok") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
  # todo sysUPSStatus, i need a device with a good ups and then a bad ups
}


