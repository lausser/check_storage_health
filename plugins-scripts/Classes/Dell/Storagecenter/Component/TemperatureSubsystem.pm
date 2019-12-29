package Classes::Dell::Storagecenter::Component::TemperatureSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["ctemperatures", "scCtlrTempTable", "Classes::Dell::Storagecenter::Component::TemperatureSubsystem::Temperature"],
    ["etemperatures", "scEnclTempTable", "Classes::Dell::Storagecenter::Component::TemperatureSubsystem::Temperature"],
  ]);
}


package Classes::Dell::Storagecenter::Component::TemperatureSubsystem::Temperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  if (exists $self->{scEnclTempCurrentC}) {
    bless $self, "Classes::Dell::Storagecenter::Component::TemperatureSubsystem::ETemperature";
    $self->{label} = lc "temp_".$self->{scEnclTempLocation};
    $self->{label} =~ s/ /_/g;
  } else {
    bless $self, "Classes::Dell::Storagecenter::Component::TemperatureSubsystem::CTemperature";
    $self->{label} = lc "temp_".$self->{scCtlrTempName};
    $self->{label} =~ s/ /_/g;
  }
}


package Classes::Dell::Storagecenter::Component::TemperatureSubsystem::ETemperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s temperature is %.2fC (%s)",
      $self->{scEnclTempLocation}, $self->{scEnclTempCurrentC},
      $self->{scEnclTempStatus});
  $self->add_ok();
  $self->add_perfdata(
      label => $self->{label},
      value => $self->{scEnclTempCurrentC},
  );
}


package Classes::Dell::Storagecenter::Component::TemperatureSubsystem::CTemperature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s temperature is %.2fC (%s)",
      $self->{scCtlrTempName}, $self->{scCtlrTempCurrentC},
      $self->{scCtlrTempStatus});
  $self->set_thresholds(
      metric => $self->{label},
      warning => $self->{scCtlrTempWarnLwrC}.":".$self->{scCtlrTempWarnUprC},
      critical => $self->{scCtlrTempCritLwrC}.":".$self->{scCtlrTempCritUprC},
  );
  $self->add_message($self->check_thresholds(
      metric => $self->{label},
      value => $self->{scCtlrTempCurrentC},
  ));
  $self->add_perfdata(
      label => $self->{label},
      value => $self->{scCtlrTempCurrentC},
  );
}
