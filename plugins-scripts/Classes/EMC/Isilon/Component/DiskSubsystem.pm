package Classes::EMC::Isilon::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
    ["disks", "diskTable", "Classes::EMC::Isilon::Component::DiskSubsystem::Disk"],
  ]);
}

package Classes::EMC::Isilon::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{name} = lc "disk_".$self->{diskDeviceName};
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "disk %s has status %s",
      $self->{name}, $self->{diskStatus});
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
}
