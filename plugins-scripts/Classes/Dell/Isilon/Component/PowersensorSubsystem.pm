package Classes::Dell::Isilon::Component::PowersensorSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
    ["powersensors", "powerSensorTable", "Classes::Dell::Isilon::Component::PowersensorSubsystem::Powersensor"],
  ]);
}

package Classes::Dell::Isilon::Component::PowersensorSubsystem::Powersensor;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s is %.2fV",
      $self->{powerSensorName}, $self->{powerSensorValue});
  $self->add_perfdata(
      label => $self->{powerSensorName},
      value => $self->{powerSensorValue},
      places => 2,
  );
}
