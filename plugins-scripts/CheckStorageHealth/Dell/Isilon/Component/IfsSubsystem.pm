package CheckStorageHealth::Dell::Isilon::Component::IfsSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ISILON-MIB", qw(ifsTotalBytes ifsUsedBytes
      ifsAvailableBytes ifsFreeBytes));
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cluster %s has status %s, %d nodes configured, %d online",
      $self->{clusterName}, $self->{clusterHealth},
      scalar(@{$self->{configured_nodes}}),
      scalar(@{$self->{online_nodes}}));
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
  if (scalar(@{$self->{online_nodes}}) < scalar(@{$self->{configured_nodes}}) / 2) {
    $self->annotate_info("less than 50% of nodes are online");
    $self->add_warning();
  }
}

