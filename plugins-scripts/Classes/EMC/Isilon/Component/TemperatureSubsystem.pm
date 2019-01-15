package Classes::EMC::Isilon::Component::TemperatureSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
    ["temperatures", "tempSensorTable", "Classes::EMC::Isilon::Component::TemperatureSubsystem::Temperature"],
  ]);
}

package Classes::EMC::Isilon::Component::TemperatureSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{tempSensorName} = $self->{tempSensorName}."_Temp" if $self->{tempSensorName} !~ /temp/i;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s is %.2fC",
      $self->{tempSensorName}, $self->{tempSensorValue});
  $self->set_thresholds(
      metric => $self->{tempSensorName},
      warning => $self->{tempSensorName} =~ /(dimm|hdd|cpu)/i ? 75 : 28,
      critical => $self->{tempSensorName} =~ /(dimm|hdd|cpu)/i ? 85 : 33,
  );
  $self->add_message($self->check_thresholds(
      metric => $self->{tempSensorName},
      value => $self->{tempSensorValue},
  ));
  $self->add_perfdata(
      label => $self->{tempSensorName},
      value => $self->{tempSensorValue},
  );
}
