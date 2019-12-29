package Classes::Dell::Isilon::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
    ["disks", "diskTable", "Classes::Dell::Isilon::Component::DiskSubsystem::Disk"],
    ["iops", "diskPerfTable", "Classes::Dell::Isilon::Component::DiskSubsystem::DiskPerf"],
  ]);
  $self->merge_tables("disks", ("iops", sub {
      my($into, $from) = @_;
      return $into->{diskBay} eq $from->{diskPerfBay} ? 1 : 0;
  }));
}


package Classes::Dell::Isilon::Component::DiskSubsystem::DiskPerf;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);


package Classes::Dell::Isilon::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{name} = lc $self->{diskDeviceName};
  $self->{name} = "disk_".$self->{name} if ! $self->{name} =~ /disk/;
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "disk %s has status %s and %d iops",
      $self->{name}, $self->{diskStatus}, $self->{diskPerfOpsPerSecond});
  if ($self->{diskStatus} eq "HEALTHY") {
    $self->add_ok();
  } elsif ($self->{diskStatus} eq "L3") {
    $self->add_ok();
  } elsif ($self->{diskStatus} eq "DEAD") {
    $self->add_critical();
  } elsif ($self->{diskStatus} eq "SMARTFAIL") {
    $self->add_warning();
  } else {
    $self->add_warning();
  }
  $self->add_perfdata(
      label => $self->{name}."_iops",
      value => $self->{diskPerfOpsPerSecond},
  );
  $self->add_perfdata(
      label => $self->{name}."_ibps",
      value => $self->{diskPerfInBitsPerSecond},
  );
  $self->add_perfdata(
      label => $self->{name}."_obps",
      value => $self->{diskPerfOutBitsPerSecond},
  );
}
