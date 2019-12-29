package Classes::Dell::Isilon::Component::CpuSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ISILON-MIB", qw(nodeCPUUser nodeCPUNice
      nodeCPUSystem nodeCPUInterrupt nodeCPUIdle));
  $self->get_snmp_tables("ISILON-MIB", [
    ["clustercpus", "clusterCPUPerf", "Classes::Dell::Isilon::Component::CpuSubsystem::ClusterCpu"],
    ["nodecpus", "nodeCPUPerfTable", "Classes::Dell::Isilon::Component::CpuSubsystem::NodeCpu"],
  ]);
  $self->{busy} = (1000 - $self->{nodeCPUIdle}) / 10;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cpu usage is %.2f%%", $self->{busy});
  $self->set_thresholds(
      metric => "cpu_usage",
      warning => 80,
      critical => 90,
  );
  $self->add_message($self->check_thresholds(
      metric => "cpu_usage",
      value => $self->{busy},
  ));
  $self->add_perfdata(
      label => "cpu_usage",
      value => $self->{busy},
      uom => "%",
  );
  foreach (@{$self->{nodecpus}}, @{$self->{clustercpus}}) {
    $_->check();
  }
}


package Classes::Dell::Isilon::Component::CpuSubsystem::NodeCpu;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{busy} = (1000 - $self->{nodePerCPUIdle}) / 10;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cpu #%d usage is %.2f%%",
      $self->{flat_indices},
      $self->{busy});
  $self->add_perfdata(
      label => sprintf("cpu_%d_usage", $self->{flat_indices}),
      value => $self->{busy},
      uom => "%",
  );
}


package Classes::Dell::Isilon::Component::CpuSubsystem::ClusterCpu;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{busy} = (1000 - $self->{clusterCPUIdlePct}) / 10;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cluster-wide cpu usage is %.2f%%",
      $self->{busy});
  $self->add_perfdata(
      label => "cluster_cpu_usage",
      value => $self->{busy},
      uom => "%",
  );
}
