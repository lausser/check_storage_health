package CheckStorageHealth::NetApp::Filer::Component::CpuSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my $self = shift;
  $self->get_snmp_objects("NETAPP-MIB", qw(cpuBusyTime cpuBusyTimePerCent
      cpuIdleTime cpuIdleTimePerCent cpuCount));
  $self->valdiff({name => 'cpu'}, qw(cpuBusyTime cpuIdleTime));
  $self->{cpu_usage} = 100 * ($self->{delta_cpuBusyTime} / 100) / $self->{delta_timestamp};
}

sub check {
  my $self = shift;
  my $errorfound = 0;
  $self->add_info('checking cpus');
  $self->add_info(sprintf 'cpu usage is %.2f%%', $self->{cpu_usage});
  $self->set_thresholds(warning => 80, critical => 90);
  $self->add_message($self->check_thresholds($self->{cpu_usage}));
  $self->add_perfdata(
      label => 'cpu_usage',
      value => $self->{cpu_usage},
      uom => '%',
  );
}

