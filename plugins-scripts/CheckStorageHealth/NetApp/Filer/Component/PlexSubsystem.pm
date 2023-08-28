package CheckStorageHealth::NetApp::Filer::Component::PlexSubsystem;
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
  $self->get_snmp_tables("NETAPP-MIB", [
      ["plexs", "plexTable", "CheckStorageHealth::NetApp::Filer::Component::PlexSubsystem::Plex"],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking plexes');
  $self->blacklist('plex', '');
  if (scalar(@{$self->{plexs}}) == 0) {
    $self->add_message(UNKNOWN, 'no plexes');
    return;
  }
  if ($self->mode =~ /device::hardware::plex::list/) {
    foreach (sort {$a->{plexName} cmp $b->{plexName}} @{$self->{plexs}}) {
      printf "%03d %s\n", $_->{plexIndex}, $_->{plexName};
      #$_->list();
    }
  } else {
    foreach (@{$self->{plexs}}) {
      $_->check();
    }
  }
}

sub dump {
  my $self = shift;
  printf "[PLEXES]\n";
  foreach (@{$self->{plexs}}) {
    $_->dump();
  }
}


package CheckStorageHealth::NetApp::Filer::Component::PlexSubsystem::Plex;
our @ISA = qw(Monitoring::GLPlugin::TableItem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub check {
  my $self = shift;
  if ($self->{plexStatus} ne 'active') {
    $self->add_message(CRITICAL,
        sprintf "plex %s is %s",
        $self->{plexName},
        $self->{plexStatus});
  } else {
    $self->add_message(OK,
        sprintf "plex %s is %s",
        $self->{plexName},
        $self->{plexStatus});
  }
}



