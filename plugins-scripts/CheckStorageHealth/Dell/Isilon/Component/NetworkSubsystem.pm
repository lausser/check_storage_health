package CheckStorageHealth::Dell::Isilon::Component::NetworkSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
      ["protos", "nodeProtocolPerfTable", "CheckStorageHealth::Dell::Isilon::Component::NetworkSubsystem::Proto"],
  ]);
}

sub check {
  my ($self) = @_;
  map { $_->check(); } @{$self->{protos}};
  $self->reduce_messages_short("protocols have no performance problems");
}


package CheckStorageHealth::Dell::Isilon::Component::NetworkSubsystem::Proto;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->valdiff({ name => "proto" }, qw(protocolOpCount));
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "protocol %s is used %.2f/s (avg. latency %.2fus)",
      $self->{protocolName}, $self->{protocolOpCount_per_sec},
      $self->{latencyAverage});
  $self->set_thresholds(
      metric => 'proto_'.$self->{protocolName}.'_avg_latency',
      warning => 800,
      critical => 1000,
  );
  $self->add_message($self->check_thresholds(
      metric => 'proto_'.$self->{protocolName}.'_avg_latency',
      value => $self->{latencyAverage},
  ));
  $self->add_perfdata(
      label => 'proto_'.$self->{protocolName}.'_in_bps',
      value => $self->{inBitsPerSecond},
  );
  $self->add_perfdata(
      label => 'proto_'.$self->{protocolName}.'_out_bps',
      value => $self->{outBitsPerSecond},
  );
  $self->add_perfdata(
      label => 'proto_'.$self->{protocolName}.'_avg_latency',
      value => $self->{latencyAverage},
      uom => "us",
      min => $self->{latencyMin},
      max => $self->{latencyMax},
  );
}
