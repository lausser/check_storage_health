package Classes::EMC::Isilon::Component::ClusterSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ISILON-MIB", qw(nodeCount configuredNodes
      offlineNodes onlineNodes clusterHealth clusterName));
  $self->{configured_nodes} = [split(",", $self->{configuredNodes})];
  $self->{online_nodes} = [split(",", $self->{onlineNodes})];
  $self->get_snmp_objects("ISILON-MIB", qw(clusterIfsInBytes
      clusterIfsInBitsPerSecond clusterIfsOutBytes
      clusterIfsOutBitsPerSecond));
  $self->get_snmp_objects("ISILON-MIB", qw(clusterNetworkInBytes
      clusterNetworkInBitsPerSecond clusterNetworkOutBytes
      clusterNetworkOutBitsPerSecond));
  $self->valdiff({ name => 'cluster_inout' }, qw(
      clusterIfsInBytes clusterIfsOutBytes clusterNetworkInBytes
      clusterNetworkOutBytes
  ));
  $self->{online_nodes_pct} = 100 * scalar(@{$self->{online_nodes}}) /
      scalar(@{$self->{configured_nodes}});
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cluster %s has status %s",
      $self->{clusterName}, $self->{clusterHealth});
  if ($self->{clusterHealth} eq "ok") {
    $self->add_ok();
  } elsif ($self->{clusterHealth} eq "down") {
    $self->add_critical();
  } elsif ($self->{clusterHealth} eq "invalid") {
    $self->add_critical();
  } elsif ($self->{clusterHealth} eq "attn") {
    $self->add_warning();
  } else {
    $self->add_warning();
  }
  $self->add_info(sprintf "%d of %d configured nodes are online (= %.2f%%)",
      scalar(@{$self->{online_nodes}}),
      scalar(@{$self->{configured_nodes}}),
      $self->{online_nodes_pct});
  $self->set_thresholds(metric => 'online_nodes_pct',
      warning => '100:',
      critical => '50:'
  );
  $self->add_message($self->check_thresholds(metric => 'online_nodes_pct',
      value => $self->{online_nodes_pct}));
  $self->add_perfdata(
      label => 'online_nodes_pct',
      value => $self->{online_nodes_pct},
  );
  $self->add_perfdata(
      label => 'cluster_ifs_out_bps',
      value => $self->{clusterIfsOutBytes_per_sec},
  );
  $self->add_perfdata(
      label => 'cluster_ifs_in_bps',
      value => $self->{clusterIfsInBytes_per_sec},
  );
  $self->add_perfdata(
      label => 'cluster_net_out_bps',
      value => $self->{clusterNetworkOutBytes_per_sec},
  );
  $self->add_perfdata(
      label => 'cluster_net_in_bps',
      value => $self->{clusterNetworkInBytes_per_sec},
  );
}
