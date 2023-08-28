package CheckStorageHealth::Dell::Datadomain::Component::PowersupplySubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(15);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
    ["powermodules", "powerModuleTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::Powersupply"],
  ]);
}

package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::Powersupply;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::Powersupply;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub finish {
  my($self) = @_;
  $self->{powerModuleStatus} ||= "--";
}

sub check {
  my($self) = @_;
  $self->add_info(sprintf "%s enc:%s/module:%s has status %s",
      $self->{powerModuleDescription}, $self->{powerEnclosureID},
      $self->{powerModuleIndex}, $self->{powerModuleStatus});
  if ($self->{powerModuleStatus} ne "ok" and $self->{powerModuleStatus} ne "--") {
    $self->add_warning_mitigation();
  } elsif ($self->{powerModuleStatus} ne "--") {
    $self->add_ok();
  }
}

__END__
sowas gibts und hat bisher fuer undefined Zeugs gesorgt,
also einmal mit und einmal ohne status. das koennte jetzt bedeuten,
dass die schlichtweg nicht verbaut sind.
Power module A pack 1 enc:2/module:1 has status ok
Power module A pack 2 enc:2/module:2 has status ok
Power module A pack 3 enc:2/module:3 has status ok
Power module A pack 4 enc:2/module:4 has status ok
Power module B pack 1 enc:2/module:5 has status ok
Power module B pack 2 enc:2/module:6 has status ok
Power module B pack 3 enc:2/module:7 has status ok
Power module B pack 4 enc:2/module:8 has status --
Power module A pack 1 enc:3/module:1 has status --
Power module A pack 2 enc:3/module:2 has status --
Power module A pack 3 enc:3/module:3 has status --
Power module A pack 4 enc:3/module:4 has status --
Power module B pack 1 enc:3/module:5 has status --
Power module B pack 2 enc:3/module:6 has status --
Power module B pack 3 enc:3/module:7 has status --
Power module B pack 4 enc:3/module:8 has status --

