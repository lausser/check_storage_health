package CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("DATA-DOMAIN-MIB", qw(vtlAdminState));
  if (defined $self->{vtlAdminState} and $self->{vtlAdminState} ne "disabled") {
    # no VTL deployed or deliberately disabled: the VTL tables are empty,
    # so fetching them only costs SNMP round-trips
    $self->get_snmp_objects("DATA-DOMAIN-MIB", qw(vtlProcessState));
    $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["vtllibraries", "vtlLibraryTable",
          "CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Library",
          sub { return $self->filter_name(shift->{vtlLibraryName}) }],
      ["vtldrives", "vtlDriveTable",
          "CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Drive"],
      ["vtlports", "vtlPortTable",
          "CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Port"],
      ["vtltapes", "vtlTapeTable",
          "CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Tape"],
       ["vtlstats", "vtlStatsLibraryTable",
           "CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::LibraryStats",
           sub { return $self->filter_name(shift->{vtlStatsLibraryName}) }],
    ]);
  }
}

sub check {
  my ($self) = @_;
  my $admin = $self->{vtlAdminState};
  my $process = $self->{vtlProcessState} // "unknown";
  if (! defined $admin) {
    # the device does not expose the VTL MIB subtree at all
    # (VTL not deployed on this appliance)
    $self->add_info("VTL is not available on this device");
    $self->add_ok();
    return;
  }
  if ($admin eq "disabled") {
    # a deliberately disabled VTL is a valid appliance configuration
    $self->add_info("VTL is disabled");
    $self->add_ok();
    return;
  }
  $self->add_info(sprintf "VTL administration state is %s", $admin);
  if ($admin eq "failed") {
    $self->add_critical_mitigation();
    return;
  }
  $self->add_info(sprintf "VTL process state is %s", $process);
  if ($process eq "starting" or $process eq "stopping") {
    $self->add_warning_mitigation();
  } elsif ($process ne "running") {
    $self->add_critical_mitigation();
  }
  foreach my $library (@{$self->{vtllibraries} || []}) {
    $library->check();
  }
  foreach my $drive (@{$self->{vtldrives} || []}) {
    $drive->check();
  }
  foreach my $port (@{$self->{vtlports} || []}) {
    $port->check();
  }
  foreach my $stats (@{$self->{vtlstats} || []}) {
    $stats->check();
  }
  my ($available, $full) = (0, 0);
  foreach my $tape (@{$self->{vtltapes} || []}) {
    my $used = $tape->{vtlTapeUsed} // "";
    # vtlTapeUsed is an OCTET STRING. tolerate a trailing unit
    # (whitespace or percent sign) before parsing the number.
    $used =~ s/[\s%]+$//;
    if ($used =~ /^\d+(\.\d+)?$/ and $used < 100) {
      $available++;
    } else {
      $full++;
    }
  }
  if (! $available and ! $full) {
    $self->add_info("VTL is enabled but vtlTapeTable reports no tapes");
    $self->add_unknown_mitigation();
  } else {
    $self->add_info(sprintf "VTL has %d available and %d full virtual tapes",
        $available, $full);
    $self->set_thresholds(
        metric => "vtl_tapes_available",
        warning => "10:",
        critical => "5:",
    );
    $self->add_message($self->check_thresholds(
        value => $available,
        metric => "vtl_tapes_available",
    ));
    $self->add_perfdata(
        label => "vtl_tapes_available",
        value => $available,
    );
    $self->add_perfdata(
        label => "vtl_tapes_full",
        value => $full,
    );
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Library;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "VTL library %s has status %s",
      $self->{vtlLibraryName}, $self->{vtlLibraryStatus});
  if (($self->{vtlLibraryStatus} // "unknown") ne "online") {
    $self->add_warning_mitigation();
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Drive;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "VTL drive %s has status %s",
      $self->{vtlDriveName}, $self->{vtlDriveStatus});
  if (($self->{vtlDriveStatus} // "unknown") ne "online") {
    $self->add_warning_mitigation();
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Port;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my ($self) = @_;
  if (($self->{vtlPortEnabled} // "unknown") eq "disabled") {
    $self->add_info(sprintf "VTL port %s is disabled", $self->{vtlPortName});
    return;
  }
  $self->add_info(sprintf "VTL port %s has status %s",
      $self->{vtlPortName}, $self->{vtlPortStatus});
  if (($self->{vtlPortStatus} // "unknown") ne "online") {
    $self->add_warning_mitigation();
  }
}

package CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::Tape;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

# no check(): tapes are only counted by the component.

package CheckStorageHealth::Dell::Datadomain::Component::TapeSubsystem::LibraryStats;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my ($self) = @_;
  my $name = $self->{vtlStatsLibraryName};
  my $soft = $self->{vtlStatsLibrarySoftErrors} || 0;
  my $hard = $self->{vtlStatsLibraryHardErrors} || 0;
  $self->add_info(sprintf "VTL library %s has %d soft and %d hard errors",
      $name, $soft, $hard);
  if ($hard > 0) {
    $self->add_critical_mitigation();
  } elsif ($soft > 0) {
    $self->add_warning_mitigation();
  }
}
