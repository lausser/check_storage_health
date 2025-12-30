package CheckStorageHealth::QNAP::NAS::Component::MemSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("NAS-MIB", qw(
      systemTotalMem systemFreeMem
  ));

  ($self->{"systemTotalMem"}) =
    $self->{"systemTotalMem"} =~ /([\d.]+)/;
  ($self->{"systemFreeMem"}) =
    $self->{"systemFreeMem"} =~ /([\d.]+)/;
}

sub check {
  my ($self) = @_;
  $self->{mem_usage} = 100 * $self->{systemFreeMem} / $self->{systemTotalMem};

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

