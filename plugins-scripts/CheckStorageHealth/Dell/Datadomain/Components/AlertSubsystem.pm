package CheckStorageHealth::Dell::Datadomain::Component::AlertSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->mult_snmp_max_msg_size(4);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["currentalerts", "currentAlertTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::CurrentAlert"],
  ]);
#  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
#      ["alerthistorys", "alertHistoryTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::AlertHistory"],
#  ]);
}

sub check {
  my ($self) = @_;
  $self->SUPER::check();
  $self->reduce_messages("no alerts");
}


package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::CurrentAlert;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
# currentAlertDescription: CIFS access over SMBv1 has been disabled.
# currentAlertID: m0-2
# currentAlertSeverity: INFO
# since looong time
  if ($self->{currentAlertSeverity} =~ /info/i) {
    #
  } elsif ($self->{currentAlertSeverity} =~ /warning/i) {
    $self->add_warning($self->{currentAlertDescription});
  } else {
    $self->add_critical($self->{currentAlertDescription});
  }
}

sub internal_content {
  my ($self) = @_;
  return $self->{currentAlertDescription};
}


package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::AlertHistory;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;


