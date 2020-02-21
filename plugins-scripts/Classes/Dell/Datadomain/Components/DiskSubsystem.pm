package Classes::Dell::Datadomain::Component::DiskSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->bulk_is_baeh(15);
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["diskperformances", "diskPerformanceTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskPerformance"],
  ]);
  $self->reset_snmp_max_msg_size();
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["nvrambatterys", "nvramBatteryTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::NvramBattery"],
      ["diskproperties", "diskPropertiesTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskProperties"],
      ["diskreliabilitys", "diskReliabilityTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskReliability"],
      ["filesystemspaces", "fileSystemSpaceTable", "Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::FileSystemSpace"],
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

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::NvramBattery;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  $self->add_info(sprintf "nvram battery %s has status %s",
      $self->{nvramBatteriesIndex}, $self->{nvramBatteryStatus});
  if ($self->{nvramBatteryStatus} ne "ok") {
    $self->add_warning_mitigation();
  }
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskPerformance;
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
  }
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskProperties;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub finish {
  my($self) = @_;
  $self->{name} = sprintf "enc:%s/disk:%s",
      $self->{diskPropEnclosureID}, $self->{diskPropIndex};
}

sub check {
  my($self) = @_;
  $self->add_info(sprintf "disk enc:%s/disk:%s (%s) has status %s",
      $self->{diskPropEnclosureID}, $self->{diskPropIndex}, $self->{diskModel},
      $self->{diskPropState});
  if ($self->{diskPropState} eq "failed") {
    $self->add_warning();
  }
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::DiskReliability;
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
  }
}

package Classes::Dell::Datadomain::Component::EnvironmentalSubsystem::FileSystemSpace;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  my $label = "fs_".$self->{fileSystemResourceName}."_usage";
  $self->add_info(sprintf "fs %s usage is %.2f%% (%d of %dGB)",
      $self->{fileSystemResourceName}, $self->{fileSystemPercentUsed},
      $self->{fileSystemSpaceUsed}, $self->{fileSystemSpaceSize});
  $self->check_thresholds(
      metric => $label,
      warning => 80,
      critical => 90,
  );
  if ($self->check_thresholds(metric => $label, value => $self->{fileSystemPercentUsed})) {
    $self->add_message($self->check_thresholds(metric => $label, value => $self->{fileSystemPercentUsed}));
  }
  $self->add_perfdata(
      label => $label,
      value => $self->{fileSystemPercentUsed},
      uom => "%",
  );
}

