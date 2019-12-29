package Classes::Dell::Storagecenter::Component::FanSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["cfans", "scCtlrFanTable", "Classes::Dell::Storagecenter::Component::FanSubsystem::Fan"],
    ["efans", "scEnclFanTable", "Classes::Dell::Storagecenter::Component::FanSubsystem::Fan"],
  ]);
}


package Classes::Dell::Storagecenter::Component::FanSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  if (exists $self->{scEnclFanStatus}) {
    bless $self, "Classes::Dell::Storagecenter::Component::FanSubsystem::EFan";
    $self->{label} = lc "fan_".$self->{scEnclFanLocation};
    $self->{label} =~ s/ /_/g;
  } else {
    bless $self, "Classes::Dell::Storagecenter::Component::FanSubsystem::CFan";
    $self->{label} = lc "fan_".$self->{scCtlrFanName};
    $self->{label} =~ s/ /_/g;
  }
}


package Classes::Dell::Storagecenter::Component::FanSubsystem::EFan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "fan %s status is %s, speed is %s",
      $self->{scEnclFanLocation}, $self->{scEnclFanStatus},
      $self->{scEnclFanCurrentS});
  if ($self->{scEnclFanStatus} ne "up") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}


package Classes::Dell::Storagecenter::Component::FanSubsystem::CFan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "fan %s status is %s",
      $self->{scCtlrFanName}, $self->{scCtlrFanStatus});
  $self->set_thresholds(
      metric => $self->{label},
      warning => $self->{scCtlrFanWarnLwrRpm}.":".$self->{scCtlrFanWarnUprRpm},
      critical => $self->{scCtlrFanCritLwrRpm}.":".$self->{scCtlrFanCritUprRpm},
  );
  $self->add_message($self->check_thresholds(
      metric => $self->{label},
      value => $self->{scCtlrFanCurrentRpm},
  ));
  $self->add_perfdata(
      label => $self->{label},
      value => $self->{scCtlrFanCurrentRpm},
  );
}
