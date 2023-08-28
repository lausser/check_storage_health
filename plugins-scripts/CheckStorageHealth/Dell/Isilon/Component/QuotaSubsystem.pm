package CheckStorageHealth::Dell::Isilon::Component::QuotaSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
    ["quotas", "quotaTable", "CheckStorageHealth::Dell::Isilon::Component::QuotaSubsystem::Quota"],
  ]);
}

package CheckStorageHealth::Dell::Isilon::Component::QuotaSubsystem::Quota;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  # geschaetzt, da lediglich die thresholds als anhaltspunkte zur
  # verfuegung stehen.
  $self->{MaxSize} = $self->{quotaHardThreshold} ||
      $self->{quotaSoftThreshold} || $self->{quotaAdvisoryThreshold};
  $self->{usage} = $self->{quotaUsage} * 100 / $self->{MaxSize};
  $self->{flexusage} = $self->{quotaUsageWithOverhead} * 100 / $self->{MaxSize};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "quota usage of %s is %.2f%%",
      $self->{quotaPath},
      $self->{usage});
  $self->set_thresholds(
      metric => "quota_".$self->{quotaPath},
      warning => $self->{quotaAdvisoryThreshold} ?
          $self->{quotaAdvisoryThreshold} * 100 / $self->{MaxSize} : 80,
      critical => $self->{quotaSoftThreshold} ?
          $self->{quotaSoftThreshold} * 100 / $self->{MaxSize}: 90,
  );
  $self->add_message($self->check_thresholds(
      metric => "quota_".$self->{quotaPath},
      value => $self->{usage},
  ));
  $self->add_perfdata(
      label => "quota_".$self->{quotaPath},
      value => $self->{usage},
      uom => "%",
      places => 1,
  );
}
