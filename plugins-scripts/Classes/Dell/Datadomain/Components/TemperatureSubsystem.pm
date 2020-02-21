package Classes::Dell::Datadomain::Component::TemperatureSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(15);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
    ["temperaturesensors", "temperatureSensorTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::TemperatureSensor"]
  ]);
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::TemperatureSensor;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  my $label = "temp_".$self->{tempSensorDescription};
  $label =~ s/(.*) Temperature.*/$1/;
  $label =~ s/(.*) Temp Relative.*/$1/;
  $label =~ s/(.*) Temp$/$1/;
  $label =~ s/\s/_/g;
  $label = lc $label;
  $self->add_info(sprintf "temperature %s has status %s (%dC)",
      $self->{tempSensorDescription}, $self->{tempSensorStatus},
      $self->{tempSensorCurrentValue});
  if ($self->{tempSensorStatus} ne "ok") {
    $self->add_warning();
  }
  $self->add_perfdata(
      label => $label,
      value => $self->{tempSensorCurrentValue},
  );
}

