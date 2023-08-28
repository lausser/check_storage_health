package CheckStorageHealth::QNAP::QuTShero::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("QTS-MIB", [
    # get_table returned 36 oids in 1s
    ["disks", "diskTable", "CheckStorageHealth::QNAP::QuTShero::Component::DiskSubsystem::Disk"],
    # auch snmpwalk/bulkwalk ist saulangsam. Schaut aus, als wurde der live
    # jede Platte einzeln abfragen.
    # get_table braucht 56s, wenn man nur diese drei oids abfragt, dann ~20s
    ["smarts", "diskSMARTInfoTable", "CheckStorageHealth::QNAP::QuTShero::Component::DiskSubsystem::Smart", undef, ["diskSMARTInfoAttributeName", "diskSMARTInfoDeviceName", "diskSMARTInfoAttributeStatus"]],
  ]);
  $self->bulk_baeh_reset();
}


package CheckStorageHealth::QNAP::QuTShero::Component::DiskSubsystem::Disk;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  $self->{diskCapacity_GB} = $self->{diskCapacity} / (1.0*1024*1024*1024);
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s disk %s status is %s (temperature: %sC)",
      $self->{diskType}, $self->{diskID},
      $self->{diskStatus},
      $self->{diskTemperature});
  if (lc $self->{diskStatus} ne "good") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}

package CheckStorageHealth::QNAP::QuTShero::Component::DiskSubsystem::Smart;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "s.m.a.r.t attribute %s of disk %s is %s",
      $self->{diskSMARTInfoAttributeName}, $self->{diskSMARTInfoDeviceName},
      $self->{diskSMARTInfoAttributeStatus});
  if (lc $self->{diskSMARTInfoAttributeStatus} ne "good") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }
}

