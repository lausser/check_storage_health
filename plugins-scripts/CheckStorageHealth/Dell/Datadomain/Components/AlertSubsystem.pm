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
  # NB: no reduce_messages() here: it would clear the OK messages of all
  # sibling subsystems that happened to be checked before us, and
  # check_subsystems() iterates in (randomized) hash order, so the
  # surviving message set would change from run to run.
  $self->add_ok("no alerts") if ! $self->check_messages();
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


