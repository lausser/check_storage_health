package Classes::Dell::Datadomain::Component::AlertSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["currentalerts", "currentAlertTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::CurrentAlert"],
  ]);
  $self->mult_snmp_max_msg_size(4);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["alerthistorys", "alertHistoryTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::AlertHistory"],
  ]);
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::CurrentAlert;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  if ($self->{currentAlertSeverity} =~ /warning/i) {
    $self->add_warning($self->{currentAlertDescription});
  } else {
    $self->add_critical($self->{currentAlertDescription});
  }
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::AlertHistory;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;


