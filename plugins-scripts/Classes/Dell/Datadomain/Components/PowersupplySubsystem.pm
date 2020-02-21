package Classes::Dell::Datadomain::Component::PowersupplySubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(15);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
    ["powermodules", "powerModuleTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::Powersupply"],
  ]);
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::Powersupply;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::Powersupply;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  $self->add_info(sprintf "%s enc:%s/module:%s has status %s",
      $self->{powerModuleDescription}, $self->{powerEnclosureID},
      $self->{powerModuleIndex}, $self->{powerModuleStatus});
  if ($self->{powerModuleStatus} ne "ok") {
    $self->add_warning_mitigation();
  }
}

