package CheckStorageHealth::QNAP::QuTShero::Component::TemperatureSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("QTS-HERO-MIB", qw(
      cpuTemperature systemTemperature
  ));
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "temperatures: cpu has %.2fC, system has %.2fC",
      $self->{cpuTemperature}, $self->{systemTemperature});
  $self->add_ok();
  $self->add_perfdata(
      label => "cpu_temp",
      value => $self->{cpuTemperature}
  );
  $self->add_perfdata(
      label => "system_temp",
      value => $self->{systemTemperature}
  );
}

