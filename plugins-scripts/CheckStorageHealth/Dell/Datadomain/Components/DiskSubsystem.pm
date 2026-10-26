package CheckStorageHealth::Dell::Datadomain::Component::DiskSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  # heuristisch rumprobiert
  $self->reset_snmp_max_msg_size();
  $self->mult_snmp_max_msg_size(10);
  $self->bulk_is_baeh(5);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["diskperformances", "diskPerformanceTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskPerformance"],
  ]);
  $self->reset_snmp_max_msg_size();
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["nvrambatterys", "nvramBatteryTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::NvramBattery"],
      ["diskproperties", "diskPropertiesTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskProperties"],
      ["diskreliabilitys", "diskReliabilityTable", "CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskReliability"],
  ]);
  foreach my $diskprop (@{$self->{diskproperties}}) {
    if ($diskprop->{diskPropState} eq "unknown") {
      # kann bedeuten, dass die Disk zum Cloud Tier gehoert und dieser nicht
      # benutzt wird.
      @{$self->{diskperformances}} = grep {
          $_->{name} ne $diskprop->{name}
      } @{$self->{diskperformances}};
      @{$self->{diskreliabilitys}} = grep {
          $_->{name} ne $diskprop->{name}
      } @{$self->{diskreliabilitys}};
    }
  }

}

package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::NvramBattery;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  $self->add_info(sprintf "nvram battery %s has status %s",
      $self->{nvramBatteriesIndex}, $self->{nvramBatteryStatus});
  if ($self->{nvramBatteryStatus} ne "ok") {
    $self->add_warning_mitigation();
  } else {
    $self->add_ok();
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskPerformance;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub finish {
  my($self) = @_;
  $self->{name} = sprintf "enc:%s/disk:%s",
      $self->{diskPerfEnclosureID}, $self->{diskPerfIndex};
}

sub check {
  my($self) = @_;
  $self->add_info(sprintf "performance of enc:%s/disk:%s is %s (%.2f%% busy)",
      $self->{diskPerfEnclosureID}, $self->{diskPerfIndex},
      $self->{diskPerfState}, $self->{diskBusy});
  if ($self->{diskPerfState} ne "ok" and $self->{diskPerfState} ne "spare") {
    $self->add_warning_mitigation();
  } else {
    $self->add_ok();
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskProperties;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub finish {
  my($self) = @_;
  $self->{name} = sprintf "enc:%s/disk:%s",
      $self->{diskPropEnclosureID}, $self->{diskPropIndex};
}

sub check {
  my($self) = @_;
  my $state = $self->{diskPropState};
  $self->add_info(sprintf "disk enc:%s/disk:%s (%s) has status %s",
      $self->{diskPropEnclosureID}, $self->{diskPropIndex}, $self->{diskModel},
      $state);
  # diskPropState is DiskStateTC (DATA-DOMAIN-MIB):
  #   ok(1) unknown(2) absent(3) failed(4) spare(5) available(6)
  #   raidReconstruction(8) copyReconstruction(9) system(10)
  #
  #   failed               real disk fault -> warn
  #   unknown, absent      not in the active data tier: reserved (e.g.
  #                        Cloud Tier) or an empty slot. Dell documents
  #                        "unknown" as normal with no alert expected
  #                        (KB 000060053); such disks are already filtered
  #                        out of diskPerformance/diskReliability in init().
  #   system               internal management disk (system metadata/boot);
  #                        healthy, just not a data disk
  #   ok, spare, available,
  #   raid/copyReconstruction
  #                        in-service data disk (reconstruction is transient
  #                        and self-healing)
  #
  # Only "failed" is a fault. Every documented non-failed state is reported
  # OK (with its real status word in the message); an unrecognised state is
  # reported UNKNOWN rather than assumed healthy.
  if ($state eq "failed") {
    $self->add_warning();
  } elsif ($state eq "ok" || $state eq "system" || $state eq "unknown"
      || $state eq "absent" || $state eq "spare" || $state eq "available"
      || $state eq "raidReconstruction" || $state eq "copyReconstruction") {
    $self->add_ok();
  } else {
    $self->add_unknown();
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskReliability;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub finish {
  my($self) = @_;
  $self->{name} = sprintf "enc:%s/disk:%s",
      $self->{diskErrEnclosureID}, $self->{diskErrIndex};
}

sub check {
  my($self) = @_;
  $self->add_info(sprintf "disk reliability enc:%s/disk:%s has status %s",
      $self->{diskErrEnclosureID}, $self->{diskErrIndex},
      $self->{diskErrState});
  if ($self->{diskErrState} ne "ok" and $self->{diskErrState} ne "spare") {
    $self->add_warning_mitigation();
  } else {
    $self->add_ok();
  }
}

