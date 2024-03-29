package CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["cpowers", "scCtlrPowerTable", "CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::Powersupply"],
    ["epowers", "scEnclPowerTable", "CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::Powersupply"],
    ["ups", "scUPSTable", "CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::UPS"],
  ]);
}

sub check {
  my ($self) = @_;
  if (! @{$self->{cpowers}} && ! @{$self->{epowers}} && ! @{$self->{ups}}) {
    $self->add_info("all power-related snmp tables are empty and i have no pertinent informations. i keep my fingers crossed.");
    $self->add_ok();
  } else {
    $self->SUPER::check();
  }
}

package CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::Powersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  if (exists $self->{scEnclPowerStatus}) {
    bless $self, "CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::EPowersupply";
    $self->{label} = lc "pwr_".$self->{scEnclPowerPosition};
    $self->{label} =~ s/ /_/g;
  } else {
    bless $self, "CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::CPowersupply";
    $self->{label} = lc "temp_".$self->{scCtlrPowerName};
    $self->{label} =~ s/ /_/g;
  }
}


package CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::EPowersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "powerctl %s has status %s",
      $self->{scEnclPowerPosition}, $self->{scEnclPowerStatus});
}


package CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::CPowersupply;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "powerctl %s has status %s",
      $self->{scCtlrPowerName}, $self->{scCtlrPowerStatus});
}


package CheckStorageHealth::Dell::Storagecenter::Component::PowersupplySubsystem::UPS;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "ups %s has status %s",
      $self->{scUPSName}, $self->{scUPSStatus});
}
