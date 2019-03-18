package Classes::EMC::Isilon::Component::StorageSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::filesystem::free/) {
    $self->get_snmp_objects("ISILON-MIB", qw(ifsTotalBytes ifsUsedBytes
        ifsAvailableBytes ifsFreeBytes accessTimeEnabled accessTimeGracePeriod
    ));
    # ifsFreeBytes ist groesser als ifsAvailableBytes, weil Platz in einem
    # Virtual Hot Spare mitgezählt wird
    $self->{ifsFreePct} = 100 * $self->{ifsAvailableBytes} / $self->{ifsTotalBytes};
  }
}

sub check {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::filesystem::free/) {
    $self->override_opt("units", "%") if ! $self->opts->units;
    my $display_units = ($self->opts->units && $self->opts->units ne "%")
        ? $self->opts->units : "GB";
    $self->add_info(sprintf "/ifs has %.2f%% free space (%.2f%s)",
        $self->{ifsFreePct},
        $self->{ifsAvailableBytes} * 8 / $self->number_of_bits($display_units),
        $display_units);
    if ($self->opts->units eq "%") {
      $self->set_thresholds(
          metric => "ifs_free_pct",
          warning => "15:",
          critical => "10:",
      );
      $self->add_message($self->check_thresholds(
          metric => "ifs_free_pct",
          value => $self->{ifsFreePct}
      ));
      $self->add_perfdata(
          label => "ifs_free_pct",
          value => $self->{ifsFreePct},
          uom => "%",
      );
    } else {
      $self->{ifsFreeUnits} = $self->{ifsAvailableBytes} / $self->number_of_bits($self->opts->units) * 8;
      $self->set_thresholds(
          metric => "ifs_free",
          warning => "15:",
          critical => "10:",
      );
      $self->add_message($self->check_thresholds(
          metric => "ifs_free",
          value => $self->{ifsFreeUnits}
      ));
      $self->add_perfdata(
          label => "ifs_free",
          value => $self->{ifsFreeUnits},
          uom => $self->opts->units,
      );
      
    }
  }
}

package Classes::EMC::Isilon::Component::StorageSubsystem::Snapshot;
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
