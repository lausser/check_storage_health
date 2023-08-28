package CheckStorageHealth::HP::Lefthand::Component::CacheSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-INFO-MIB", [
    ["caches", "infoCacheTable", "CheckStorageHealth::HP::Lefthand::Component::CacheSubsystem::Cache"],
  ]);
}


package CheckStorageHealth::HP::Lefthand::Component::CacheSubsystem::Cache;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s has status %s,%s",
      $self->{infoCacheName}, $self->{infoCacheState},
      $self->{infoCacheStatus});
  if ($self->{infoCacheStatus} ne "pass") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
  $self->add_info(sprintf "%s BBU has status %s,%s",
      $self->{infoCacheName}, $self->{infoCacheBbuState},
      $self->{infoCacheBbuStatus});
  if ($self->{infoCacheBbuStatus} ne "pass") {
    $self->add_critical();
  } else {
    $self->add_ok();
  }
  if ($self->{infoCacheEnabled} ne "1") {
    $self->add_info(sprintf "%s is disabled", $self->{infoCacheName});
    $self->add_warning();
  }
}

