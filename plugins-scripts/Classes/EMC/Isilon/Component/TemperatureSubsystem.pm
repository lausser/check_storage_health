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
  # Wir haben wegen der ISILON Minus-Temperatur mal nachgefragt und folgende Antwort bekommen:
  # Das ist kein Bug sondern es wird kein absoluter Wert zurückgeliefert. Du musst den Wert -53.000 so verstehen, dass dieser 53° bis zum „Problem“ entfernt ist  sprich bei 0 wird es problematisch.
  # Glauben tu ich das zwar nicht, aber kannst du das bei diesem Wert „CPU0_Temp“ berücksichtigen?
  # Ich glaub's auch nicht. Aber -46 Grad an einer CPU auch nicht, also
  # nicht weiter nachgrübeln und glatthobeln.
  $self->{tempSensorValue} = abs($self->{tempSensorValue});
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
