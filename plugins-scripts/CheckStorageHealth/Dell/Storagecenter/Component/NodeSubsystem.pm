package CheckStorageHealth::Dell::Storagecenter::Component::NodeSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["nodes", "scServerTable", "CheckStorageHealth::Dell::Storagecenter::Component::NodeSubsystem::Node"],
  ]);
}


package CheckStorageHealth::Dell::Storagecenter::Component::NodeSubsystem::Node;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "node %s status is %s",
      $self->{scServerName}, $self->{scServerStatus});
  if ($self->{scServerCnctvy} eq "down") {
    $self->annotate_info("connectivity is ".$self->{scServerCnctvy});
    $self->add_critical();
  } elsif ($self->{scServerCnctvy} eq "partial") {
    $self->annotate_info("connectivity is ".$self->{scServerCnctvy});
    $self->add_warning();
  }
  if ($self->{scServerStatus} eq "degraded") {
    $self->add_warning();
  } elsif ($self->{scServerStatus} eq "down") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
}


package CheckStorageHealth::Dell::Storagecenter::Component::NodeSubsystem::CNode;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "fan %s status is %s",
      $self->{scCtlrNodeName}, $self->{scCtlrNodeStatus});
  $self->set_thresholds(
      metric => $self->{label},
      warning => $self->{scCtlrNodeWarnLwrRpm}.":".$self->{scCtlrNodeWarnUprRpm},
      critical => $self->{scCtlrNodeCritLwrRpm}.":".$self->{scCtlrNodeCritUprRpm},
  );
  $self->add_message($self->check_thresholds(
      metric => $self->{label},
      value => $self->{scCtlrNodeCurrentRpm},
  ));
  $self->add_perfdata(
      label => $self->{label},
      value => $self->{scCtlrNodeCurrentRpm},
  );
}
