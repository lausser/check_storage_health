package Classes::NetApp::Filer::Component::VolumeSubsystem;
our @ISA = qw(Classes::NetApp::Filer);

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
  $self->get_snmp_tables("NETAPP-MIB", [
      ["volumes", "volTable", "Classes::NetApp::Filer::Component::VolumeSubsystem::Volume"],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking volumes');
  $self->blacklist('volume', '');
  if (scalar(@{$self->{volumes}}) == 0) {
    $self->add_message(UNKNOWN, 'no volumees');
    return;
  }
  if ($self->mode =~ /device::hardware::volume::list/) {
    foreach (sort {$a->{volName} cmp $b->{volName}} @{$self->{volumes}}) {
      printf "%03d %s\n", $_->{volIndex}, $_->{volName};
      #$_->list();
    }
  } else {
    foreach (@{$self->{volumes}}) {
      $_->check();
    }
  }
}

sub dump {
  my $self = shift;
  printf "[VOLUMES]\n";
  foreach (@{$self->{volumes}}) {
    $_->dump();
  }
}


package Classes::NetApp::Filer::Component::VolumeSubsystem::Volume;
our @ISA = qw(Monitoring::GLPlugin::TableItem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub check {
  my $self = shift;
  if ($self->{volStatus} !~ /normal/) {
    $self->add_message(CRITICAL,
        sprintf "volume %s is %s",
        $self->{volName},
        $self->{volStatus});
  } else {
    $self->add_message(OK,
        sprintf "volume %s is %s",
        $self->{volName},
        $self->{volStatus});
  }
}



