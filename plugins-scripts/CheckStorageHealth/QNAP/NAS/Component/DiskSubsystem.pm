package CheckStorageHealth::QNAP::NAS::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("NAS-MIB", [
    ["disks", "systemHdTable", "CheckStorageHealth::QNAP::NAS::Component::DiskSubsystem::Disk"],
  ]);

}

package CheckStorageHealth::QNAP::NAS::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;

  $self->{hdModel} =~ s/^\s+|\s+$//g;
  $self->{hdTemperature} =~ s/\s.*//;

  $self->add_info(sprintf "%s disk %s status is %s (temperature: %sC)",
      $self->{hdModel}, $self->{hdIndex},
      $self->{hdStatus},
      $self->{hdTemperature});

  $self->add_perfdata(
      label => sprintf("%s_temp", lc $self->{hdDescr}),
      value => $self->{hdTemperature}
  );

  $self->annotate_info(sprintf("smart: %s", lc($self->{hdSmartInfo})));

  if((lc $self->{hdStatus} ne "ready") || (lc $self->{hdSmartInfo} ne "good")) {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}
