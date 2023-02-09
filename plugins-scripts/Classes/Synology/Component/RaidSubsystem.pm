package Classes::Synology::Component::RaidSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("SYNOLOGY-RAID-MIB", [
    ["raids", "raidTable", "Classes::Synology::Component::RaidSubsystem::Raid"],
  ]);
}


package Classes::Synology::Component::RaidSubsystem::Raid;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "raid %s status is %s",
      $self->{raidName}, $self->{raidStatus});
  if ($self->{raidStatus} eq "Normal") {
    $self->add_ok();
  } elsif ($self->{raidStatus} eq "Degrade") {
    $self->add_warning();
  } elsif ($self->{raidStatus} eq "Crashed") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}
