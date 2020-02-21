package Classes::Dell::Datadomain::Component::FanSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(15);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
    ["fanproperties", "fanPropertiesTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::FanProperties"],
  ]);
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::FanProperties;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  $self->add_info(sprintf "fan enc:%s/fan:%s has status %s",
      $self->{fanEnclosureID}, $self->{fanIndex}, $self->{fanStatus});
  if ($self->{fanStatus} ne "ok") {
    $self->add_warning_mitigation();
  }
}

