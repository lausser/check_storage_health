package CheckStorageHealth::QNAP::QuTShero::Component::MemSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("QTS-HERO-MIB", qw(
      systemTotalMem systemFreeMem systemAvailableMem systemUsedMemory
      systemCacheMemory systemBufferMemory
  ));
}

sub check {
  my ($self) = @_;
  # i tried several ways to calculate the used memory. (also copying the
  # ucd-mib with cache and buffers as available memories)
  # the only formula which is identical to the value shown in the web gui:
  $self->{mem_avail} = 100 * $self->{systemAvailableMem} / $self->{systemTotalMem};
  $self->{mem_usage} = 100 - $self->{mem_avail};

  $self->add_info(sprintf 'memory usage is %.2f%%',
      $self->{mem_usage});
  $self->set_thresholds(
      metric => 'memory_usage',
      warning => 80,
      critical => 90);
  $self->add_message($self->check_thresholds(
      metric => 'memory_usage',
      value => $self->{mem_usage}));
  $self->add_perfdata(
      label => 'memory_usage',
      value => $self->{mem_usage},
      uom => '%',
  );
}

