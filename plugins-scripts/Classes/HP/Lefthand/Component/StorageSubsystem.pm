package Classes::HP::Lefthand::Component::StorageSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::filesystem::free/) {
    $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-CLUSTERING-MIB", [
      ["volumes", "clusVolumeTable", "Classes::HP::Lefthand::Component::StorageSubsystem::Volume",  sub { return $self->filter_name(shift->{clusVolumeName}) }],
    ]);
  }
}

package Classes::HP::Lefthand::Component::StorageSubsystem::Volume;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::filesystem::free/) {
    $self->override_opt("units", "%") if ! $self->opts->units;
    my $display_units = ($self->opts->units && $self->opts->units ne "%")
        ? $self->opts->units : "GB";
    $self->add_info(sprintf "%s has %.2f%% free space (%.2f%s)",
        $self->{clusVolumeName},
        100 - $self->{clusVolumeUsedPercent},
        $self->{clusVolumeAvailableSpace} * 8 / $self->number_of_bits($display_units),
        $display_units);
    if ($self->opts->units eq "%") {
      $self->set_thresholds(
          metric => $self->{clusVolumeName}."_free_pct",
          warning => "15:",
          critical => "10:",
      );
      $self->add_message($self->check_thresholds(
          metric => $self->{clusVolumeName}."_free_pct",
          value => 100 - $self->{clusVolumeUsedPercent}
      ));
      $self->add_perfdata(
          label => $self->{clusVolumeName}."_free_pct",
          value => 100 - $self->{clusVolumeUsedPercent},
          uom => "%",
      );
    } else {
      $self->{freeUnits} = $self->{clusVolumeAvailableSpace} / $self->number_of_bits($self->opts->units) * 8;
      $self->set_thresholds(
          metric => $self->{clusVolumeName}."_free",
          warning => "15:",
          critical => "10:",
      );
      $self->add_message($self->check_thresholds(
          metric => $self->{clusVolumeName}."_free",
          value => $self->{freeUnits}
      ));
      $self->add_perfdata(
          label => $self->{clusVolumeName}."_free",
          value => $self->{freeUnits},
          uom => $self->opts->units,
      );
    }
    if ($self->{clusVolumeIsFull} eq "1") {
      $self->add_info($self->{clusVolumeName}." is full");
      $self->add_critical();
    }
  }
}

package Classes::HP::Lefthand::Component::StorageSubsystem::Snapshot;
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
