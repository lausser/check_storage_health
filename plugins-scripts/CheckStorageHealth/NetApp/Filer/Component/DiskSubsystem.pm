package CheckStorageHealth::NetApp::Filer::Component::DiskSubsystem;
our @ISA = qw(CheckStorageHealth::NetApp::Filer);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub new {
  my $class = shift;
  my $self = {
    blacklisted => 0,
    info => undef,
    extendedinfo => undef,
  };
  bless $self, $class;
  $self->init();
  return $self;
}

sub init {
  my $self = shift;
  $self->get_snmp_objects("NETAPP-MIB", qw(diskTotalCount diskActiveCount 
      diskReconstructingCount diskReconstructingParityCount
      diskVerifyingParityCount diskScrubbingCount diskFailedCount
      diskSpareCount diskAddingSpareCount diskFailedMessage
      diskPrefailedCount));
  $self->get_snmp_tables("NETAPP-MIB", [
      ["raids", "raidTable", "Monitoring::GLPlugin::TableItem"],
      ["spares", "spareTable", "Monitoring::GLPlugin::TableItem"],
      ["vraids", "raidVTable", "CheckStorageHealth::NetApp::Filer::Component::RaidSubsystem::VRaid"],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking raids');
  $self->blacklist('raid', '');
  if (scalar(@{$self->{vraids}}) == 0) {
    $self->add_message(UNKNOWN, 'no raids');
    return;
  }
  if ($self->mode =~ /device::hardware::raid::list/) {
    foreach (sort {$a->{raidDiskName} cmp $b->{raidDiskName}} @{$self->{raids}}) {
      printf "%03d %s\n", $_->{raidIndex}, $_->{raidDiskName};
      #$_->list();
    }
  } else {
    foreach (@{$self->{vraids}}) {
      $_->check();
    }
  }
}

sub xdump {
  my $self = shift;
  printf "[DISKS]\n";
  foreach (qw(diskTotalCount diskActiveCount 
      diskReconstructingCount diskReconstructingParityCount
      diskVerifyingParityCount diskScrubbingCount diskFailedCount
      diskSpareCount diskAddingSpareCount diskFailedMessage
      diskPrefailedCount)) {
    printf "%s: %s\n", $_, $self->{$_};
  }
  foreach (@{$self->{vraids}}) {
    $_->dump();
  }
}


package CheckStorageHealth::NetApp::Filer::Component::RaidSubsystem::VRaid;
our @ISA = qw(Monitoring::GLPlugin::TableItem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub check {
  my $self = shift;
  if ($self->{raidVStatus} ne 'active') {
    $self->add_message(CRITICAL,
        sprintf "disk %s is %s",
        $self->{raidVDiskName},
        $self->{raidVStatus});
  } else {
    $self->add_message(OK,
        sprintf "disk %s is %s",
        $self->{raidVDiskName},
        $self->{raidVStatus});
  }
}



