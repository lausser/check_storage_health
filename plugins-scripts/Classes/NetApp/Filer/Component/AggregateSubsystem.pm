package Classes::NetApp::Filer::Component::AggregateSubsystem;
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
      ["aggregates", "aggrTable", "Classes::NetApp::Filer::Component::AggregateSubsystem::Aggregate"],
  ]);
}

sub check {
  my $self = shift;
  $self->add_info('checking aggregates');
  $self->blacklist('aggregate', '');
  if (scalar(@{$self->{aggregates}}) == 0) {
    $self->add_message(UNKNOWN, 'no aggregates');
    return;
  }
  if ($self->mode =~ /device::hardware::aggregate::list/) {
    foreach (sort {$a->{aggrName} cmp $b->{aggrName}} @{$self->{aggregates}}) {
      printf "%03d %s\n", $_->{aggrIndex}, $_->{aggrName};
      #$_->list();
    }
  } else {
    foreach (@{$self->{aggregates}}) {
      $_->check();
    }
  }
}

sub dump {
  my $self = shift;
  printf "[VOLUMES]\n";
  foreach (@{$self->{aggregates}}) {
    $_->dump();
  }
}


package Classes::NetApp::Filer::Component::AggregateSubsystem::Aggregate;
our @ISA = qw(Monitoring::GLPlugin::TableItem);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub check {
  my $self = shift;
  if ($self->{aggrStatus} !~ /normal/) {
    $self->add_message(CRITICAL,
        sprintf "aggregate %s is %s",
        $self->{aggrName},
        $self->{aggrStatus});
  } else {
    $self->add_message(OK,
        sprintf "aggregate %s is %s",
        $self->{aggrName},
        $self->{aggrStatus});
  }
}



