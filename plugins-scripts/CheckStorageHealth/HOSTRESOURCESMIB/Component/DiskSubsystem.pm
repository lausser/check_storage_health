package CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_tables('HOST-RESOURCES-MIB', [
      ['storages', 'hrStorageTable', 'CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem::Storage', sub { my $o = shift; return ($o->{hrStorageType} eq 'hrStorageFixedDisk' and $self->filter_name($o->{hrStorageDescr})) }],
      ['filesystems', 'hrFSTable', 'CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem::FS'],
  ]);
  $self->merge_tables_with_code("storages", "filesystems", sub {
      my ($storage, $fs) = @_;
      return ($storage->{hrStorageIndex} eq $fs->{hrFSStorageIndex}) ? 1 : 0;
  });
  @{$self->{storages}} = grep {
    ! $_->{bindmount};
  } @{$self->{storages}};
}


package CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem::FS;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  $self->{hrFSMountPoint} ||= $self->{hrFSRemoteMountPoint};
}


package CheckStorageHealth::HOSTRESOURCESMIB::Component::DiskSubsystem::Storage;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  if ($self->{hrStorageDescr} =~ /(.*?),*\s+mounted on:\s+(.*)/) {
    my ($dev, $mnt) = ($1, $2);
    if ($dev =~ /^dev/) {
      $self->{name} = 'devfs_'.$mnt;
      $self->{device} = 'devfs';
      $self->{mountpoint} = $mnt;
    } else {
      $self->{name} = $dev.'_'.$mnt;
      $self->{device} = $dev;
      $self->{mountpoint} = $mnt;
    }
  } else {
    $self->{name} = $self->{hrStorageDescr};
  }
  if ($self->{hrStorageDescr} eq "/dev" || $self->{hrStorageDescr} =~ /^devfs/ ||
      $self->{hrStorageDescr} =~ /.*cdrom.*/ || $self->{hrStorageSize} == 0 ||
      $self->{hrStorageDescr} =~ /.*iso$/) {
    $self->{special} = 1;
  } else {
    $self->{special} = 0;
  }
  if ($self->{hrStorageDescr} =~ /^\/var\/lib\/kubelet\/pods\/.*\/volumes\/.*$/ ||
      $self->{hrStorageDescr} =~ /^\/var\/lib\/kubelet\/pods\/.*\/volume-subpaths\/.*$/ ||
      $self->{hrStorageDescr} =~ /^\/run\/k3s\/containerd\/.*\/sandboxes\/.*$/) {
    $self->{bindmount} = 1;
  }
}

sub check {
  my ($self) = @_;
  if ($self->mode =~ /device::storage::filesystem::free/) {
    my $free = 100;
    eval {
       $free = 100 - 100 * $self->{hrStorageUsed} / $self->{hrStorageSize};
    };
    $self->add_info(sprintf 'storage %s (%s) has %.2f%% free space left',
        $self->{hrStorageIndex},
        $self->{hrStorageDescr},
        $free);
    if ($self->{special}) {
      # /dev is usually full, so we ignore it. size 0 is virtual crap
      $self->set_thresholds(metric => sprintf('%s_free_pct', $self->{name}),
          warning => '0:', critical => '0:');
    } else {
      $self->set_thresholds(metric => sprintf('%s_free_pct', $self->{name}),
          warning => '10:', critical => '5:');
    }
    $self->add_message($self->check_thresholds(metric => sprintf('%s_free_pct', $self->{name}),
        value => $free));
    $self->add_perfdata(
        label => sprintf('%s_free_pct', $self->{name}),
        value => $free,
        uom => '%',
    );
  } elsif ($self->mode =~ /device::storage::filesystem::writable/) {
    $self->add_info(sprintf 'storage %s (mountpoint %s) is %swritable',
        $self->{hrStorageIndex}, $self->{hrFSMountPoint},
        ($self->{hrFSAccess} eq "readWrite") ? "" : "not"
    );
    if ($self->{hrFSAccess} eq "readWrite") {
      $self->add_ok();
    } else {
      $self->add_critical_mitigation();
    }
  }
}

