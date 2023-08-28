package CheckStorageHealth::HP::Lefthand::Component::TemperatureSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-INFO-MIB", [
    ["temperatures", "infoTemperatureSensorTable", "CheckStorageHealth::HP::Lefthand::Component::TemperatureSubsystem::Temperature"],
  ]);
}


package CheckStorageHealth::HP::Lefthand::Component::TemperatureSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s temperature is %.2fC (%s,%s)",
      $self->{infoTemperatureSensorName}, $self->{infoTemperatureSensorValue},
      $self->{infoTemperatureSensorState}, $self->{infoTemperatureSensorStatus});
  if ($self->{infoTemperatureSensorStatus} ne "pass") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
  $self->{infoTemperatureSensorName} =~ s/[()]//g;
  $self->{infoTemperatureSensorName} =~ s/ /_/g;
  $self->add_perfdata(
      label => lc "temp_".$self->{infoTemperatureSensorName},
      value => $self->{infoTemperatureSensorValue},
      warning => $self->{infoTemperatureSensorLimit},
      critical => $self->{infoTemperatureSensorCritical},
  );
}

