package Classes::Dell::Storagecenter::Component::PowersupplySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["cpowers", "scCtlrPowerTable", "Classes::Dell::Storagecenter::Component::PowersupplySubsystem::Powersupply"],
    ["epowers", "scEnclPowerTable", "Classes::Dell::Storagecenter::Component::PowersupplySubsystem::Powersupply"],
    ["ups", "scUPSTable", "Classes::Dell::Storagecenter::Component::PowersupplySubsystem::UPS"],
  ]);
}


package Classes::Dell::Storagecenter::Component::PowersupplySubsystem::Powersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  if (exists $self->{scEnclPowerStatus}) {
    bless $self, "Classes::Dell::Storagecenter::Component::PowersupplySubsystem::EPowersupply";
    $self->{label} = lc "pwr_".$self->{scEnclPowerPosition};
    $self->{label} =~ s/ /_/g;
  } else {
    bless $self, "Classes::Dell::Storagecenter::Component::PowersupplySubsystem::CPowersupply";
    $self->{label} = lc "temp_".$self->{scCtlrPowerName};
    $self->{label} =~ s/ /_/g;
  }
}


package Classes::Dell::Storagecenter::Component::PowersupplySubsystem::EPowersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "powerctl %s has status %s",
      $self->{scEnclPowerPosition}, $self->{scEnclPowerStatus});
}


package Classes::Dell::Storagecenter::Component::PowersupplySubsystem::CPowersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "powerctl %s has status %s",
      $self->{scCtlrPowerName}, $self->{scCtlrPowerStatus});
}


package Classes::Dell::Storagecenter::Component::PowersupplySubsystem::UPS;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "ups %s has status %s",
      $self->{scUPSName}, $self->{scUPSStatus});
}
