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

# Shared severity mapping for the Data Domain DiskStateTC textual convention.
# diskPropState, diskPerfState and diskErrState all use DiskStateTC, so every
# per-disk item must judge a state the same way - this keeps the three tables
# from disagreeing (a divergence previously made an "available" disk report
# WARNING in diskPerformance while diskProperties reported it as OK).
#
# Source: DATA-DOMAIN-MIB (MIBS/DATA_DOMAIN.mib, DiskStateTC) + Dell
# KB 000021916 ("How to Identify and Resolve Disk States") and KB 000060053.
#   failed  (F)  disk fault, "address immediately"            -> WARNING
#   absent  (A)  no comm to an inserted disk (reseat/rescan)  -> WARNING
#   ok (.)     in use / working                                -> OK
#   spare (s)  hot spare                                       -> OK
#   available(V) healthy, just not allocated to a tier yet     -> OK (neutral)
#   unknown (U) reserved (Cloud Tier) / empty slot (KB 000060053) -> OK
#   system (Y) internal management disk                        -> OK
#   raidReconstruction (R) / copyReconstruction (C) transient  -> OK
#   anything else (e.g. a value added by newer firmware)        -> UNKNOWN
# Note: a genuinely empty slot is "Not-Installed" in the KB, which has no
# DiskStateTC value in this MIB; such slots report as "unknown" (reserved),
# not "absent". So "absent" specifically means a disk that is present but not
# communicating - a real problem.
sub diskstate_severity {
  my ($state) = @_;
  return 'WARNING'
      if defined $state and $state =~ /\A(failed|absent)\z/;
  return 'OK'
      if defined $state and $state =~
          /\A(ok|unknown|spare|available|system|raidReconstruction|copyReconstruction)\z/;
  return 'UNKNOWN';
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
  my $severity =
      CheckStorageHealth::Dell::Datadomain::Component::DiskSubsystem::diskstate_severity(
          $self->{diskPerfState});
  if ($severity eq "WARNING") {
    $self->add_warning_mitigation();
  } elsif ($severity eq "UNKNOWN") {
    $self->add_unknown_mitigation();
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
  # diskPropState is DiskStateTC; the shared diskstate_severity() classifier
  # maps it to a severity so all three disk tables agree. "failed" (and
  # "absent", a present-but-not-communicating disk) are faults (WARNING); the
  # documented benign states report OK with their real status word; an
  # unrecognised state reports UNKNOWN.
  my $severity =
      CheckStorageHealth::Dell::Datadomain::Component::DiskSubsystem::diskstate_severity(
          $state);
  if ($severity eq "WARNING") {
    $self->add_warning();
  } elsif ($severity eq "UNKNOWN") {
    $self->add_unknown();
  } else {
    $self->add_ok();
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
  # diskErrState is DiskStateTC; use the same shared classifier as the other
  # two disk tables so an "available" or "system" disk is judged consistently.
  my $severity =
      CheckStorageHealth::Dell::Datadomain::Component::DiskSubsystem::diskstate_severity(
          $self->{diskErrState});
  if ($severity eq "WARNING") {
    $self->add_warning_mitigation();
  } elsif ($severity eq "UNKNOWN") {
    $self->add_unknown_mitigation();
  } else {
    $self->add_ok();
  }
}

