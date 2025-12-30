package CheckStorageHealth::QNAP::NAS::Component::TemperatureSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub normalize_vals {
    my ($v) = @_;
    return undef
        if $v =~ /^\s*$/ || $v eq '0';
    if ($v =~ /([\d.]+)/) {
        return $1;
    }
    return undef;
}

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("NAS-MIB", qw(
      cpu-Temperature systemTemperature
  ));

  ($self->{"cpu-Temperature"}) = normalize_vals($self->{"cpu-Temperature"});
  ($self->{"systemTemperature"}) = normalize_vals($self->{"systemTemperature"});
}

sub check {
  my ($self) = @_;
  my @parts;
  push @parts, sprintf("cpu has %.2fC",    $self->{cpuTemperature})
      if defined $self->{cpuTemperature};

  push @parts, sprintf("system has %.2fC", $self->{systemTemperature})
      if defined $self->{systemTemperature};
  $self->add_info("temperatures: " . join(", ", @parts)) if @parts;

  $self->add_ok();
  $self->add_perfdata(
      label => "cpu_temp",
      value => $self->{cpuTemperature}
  )
      if defined $self->{cpuTemperature};
  $self->add_perfdata(
      label => "system_temp",
      value => $self->{systemTemperature}
  )
      if defined $self->{systemTemperature};

}

