package Classes::HP::Lefthand::Component::StorageSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::filesystem::free/) {
    $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-CLUSTERING-MIB", [
      ["volumes", "clusVolumeTable", "Classes::HP::Lefthand::Component::StorageSubsystem::Volume",  sub { return $self->filter_name(shift->{clusVolumeName}) }],
    ]);
  } elsif ($self->mode =~ /device::storage::cluster::free/) {
    $self->get_snmp_tables("LEFTHAND-NETWORKS-NSM-CLUSTERING-MIB", [
      #["modules", "clusModuleTable", "Classes::HP::Lefthand::Component::StorageSubsystem::Module"],
      ["clusters", "clusClusterTable", "Classes::HP::Lefthand::Component::StorageSubsystem::Cluster"],
    ]);
  }
}

package Classes::HP::Lefthand::Component::StorageSubsystem::Cluster;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use POSIX qw(ceil);

sub finish {
  my ($self) = @_;
  foreach (qw(clusClusterAvailableSpace clusClusterStatsKbytesRead
      clusClusterStatsKbytesWrite clusClusterTotalSpace
      clusClusterProvisionedSpace clusClusterUsedSpace)) {
    if (exists $self->{$_} && $self->{$_}) {
      $self->{$_} *= 1024;
      $self->{$_."_GB"} = $self->{$_} / (1.0*1024*1024*1024);
    }
  }
  $self->{clusClusterUsedPercent} = ceil($self->{clusClusterUsedSpace} / $self->{clusClusterTotalSpace} * 100.0);
  # konkretes Beispiel: clusClusterUtilization ist 84, aber in der Gui
  # steht "Cluster total space is 85% full".
  # clusClusterUsedPercent ist 84.889, anscheinend wird in der Gui aufgerundet,
  # per SNMP aber abgerundet.
}

sub check {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::cluster::free/) {
    $self->override_opt("units", "%") if ! $self->opts->units;
    my $display_units = ($self->opts->units && $self->opts->units ne "%")
        ? $self->opts->units : "GiB";
    $self->add_info(sprintf "%s has %.2f%% available space (%.2f%s)",
        $self->{clusClusterName},
        100 - $self->{clusClusterUsedPercent},
        $self->{clusClusterAvailableSpace} * 8 / $self->number_of_bits($display_units),
        $display_units);
    if ($self->opts->units eq "%") {
      $self->set_thresholds(
          metric => $self->{clusClusterName}."_free_pct",
          warning => "16:",
          critical => "10:",
      );
      $self->add_message($self->check_thresholds(
          metric => $self->{clusClusterName}."_free_pct",
          value => 100 - $self->{clusClusterUsedPercent}
      ));
      $self->add_perfdata(
          label => $self->{clusClusterName}."_free_pct",
          value => 100 - $self->{clusClusterUsedPercent},
          uom => "%",
      );
    } else {
      $self->{freeUnits} = $self->{clusClusterAvailableSpace} / $self->number_of_bits($self->opts->units) * 8;
      $self->{warnUnits} = (15/100.0 * $self->{clusClusterTotalSpace}) / $self->number_of_bits($self->opts->units) * 8;
      $self->{critUnits} = (10/100.0 * $self->{clusClusterTotalSpace}) / $self->number_of_bits($self->opts->units) * 8;
      $self->set_thresholds(
          metric => $self->{clusClusterName}."_free",
          warning => $self->{warnUnits}.":",
          critical => $self->{critUnits}.":",
      );
      $self->add_message($self->check_thresholds(
          metric => $self->{clusClusterName}."_free",
          value => $self->{freeUnits}
      ));
      $self->add_perfdata(
          label => $self->{clusClusterName}."_free",
          value => $self->{freeUnits},
          uom => $self->opts->units,
          places => 1,
      );
    }
  }
}

package Classes::HP::Lefthand::Component::StorageSubsystem::Module;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  foreach (qw(clusModuleUsableSpace clusModuleAvailableSpace
      clusModuleStatsKbytesRead clusModuleStatsKbytesWrite
      clusModuleProvisionedSpace clusModuleUsedSpace)) {
    if (exists $self->{$_} && $self->{$_}) {
      $self->{$_} *= 1024;
      $self->{$_."_GB"} = $self->{$_} / (1.0*1024*1024*1024);
    }
  }
}

package Classes::HP::Lefthand::Component::StorageSubsystem::Volume;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  foreach (qw(clusVolumeSize clusVolumeSoftThreshold clusVolumeHardThreshold
      clusVolumeUsedSpace clusVolumeProvisionedSpace clusVolumeStatsKbytesRead
      clusVolumeStatsKbytesWrite clusVolumeAvailableSpace)) {
    if (exists $self->{$_} && $self->{$_}) {
      $self->{$_} *= 1024;
      $self->{$_."_GB"} = $self->{$_} / (1.0*1024*1024*1024);
    }
  }
}

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
    #if ($self->{clusVolumeIsFull} eq "1") {
    #  $self->add_info($self->{clusVolumeName}." is full");
    #  $self->add_critical();
    #}
  }
}

