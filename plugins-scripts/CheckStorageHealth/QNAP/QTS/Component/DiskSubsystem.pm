package CheckStorageHealth::QNAP::QTS::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("QTS-MIB", [
    ["disks", "diskTable", "CheckStorageHealth::QNAP::QTS::Component::DiskSubsystem::Disk"],
  ]);
}

