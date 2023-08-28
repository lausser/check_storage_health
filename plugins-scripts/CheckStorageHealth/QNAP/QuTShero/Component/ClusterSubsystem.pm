package CheckStorageHealth::QNAP::QuTShero::Component::ClusterSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-CLUSTERING-MIB", [
    ["cmanagers", "clusManagerTable", "CheckStorageHealth::QNAP::QuTShero::Component::ClusterSubsystem::ClusterManager"],
    ["cmodule", "clusModuleTable", "CheckStorageHealth::QNAP::QuTShero::Component::ClusterSubsystem::ClusterModule"],
  ]);
}


package CheckStorageHealth::QNAP::QuTShero::Component::ClusterSubsystem::ClusterManager;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cluster manager %s status is %s",
      $self->{clusManagerName}, $self->{clusManagerStatus});
  if ($self->{clusManagerStatus} ne "up") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}


package CheckStorageHealth::QNAP::QuTShero::Component::ClusterSubsystem::ClusterModule;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cluster module %s status is %s,%s",
      $self->{clusModuleName}, $self->{clusModuleStorageState},
      $self->{clusModuleStorageStatus});
  if ($self->{clusModuleStorageState} ne "ok" ||
      $self->{clusModuleStorageStatus} ne "up") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}
