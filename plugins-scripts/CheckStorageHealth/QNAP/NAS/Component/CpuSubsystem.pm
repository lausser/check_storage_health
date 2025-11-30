package CheckStorageHealth::QNAP::NAS::Component::CpuSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("NAS-MIB", qw(
    systemCPU-Usage
  ));

  ($self->{"systemCPU-Usage"}) =
    $self->{"systemCPU-Usage"} =~ /([\d.]+)/;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "cpu usage is %.2f%%",
      $self->{"systemCPU-Usage"});
  $self->set_thresholds(warning => '80', critical => '90');
  $self->add_message($self->check_thresholds($self->{"systemCPU-Usage"}));
  $self->add_perfdata(
      label => "cpu_usage",
      value => $self->{"systemCPU-Usage"},
      uom => "%",
  );
}

