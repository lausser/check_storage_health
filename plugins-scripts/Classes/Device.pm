package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin::SNMP);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_unknown('either specify a hostname or a snmpwalk file');
  } else {
    $self->check_snmp_and_model();
    if (! $self->check_messages()) {
      $self->debug("I am a ".$self->{productname}."\n");
      if ($self->opts->mode =~ /^my-/) {
        $self->load_my_extension();
      } elsif ($self->{productname} =~ /netapp/i) {
        bless $self, 'Classes::NetApp';
        $self->debug('using Classes::NetApp');
      } elsif ($self->implements_mib('NETAPP-MIB')) {
        bless $self, 'Classes::NetApp';
        $self->debug('using Classes::NetApp');
      } elsif ($self->implements_mib('ISILON-MIB')) {
        bless $self, 'Classes::EMC::Isilon';
        $self->debug('using Classes::EMC::Isilon');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          bless $self, $class;
          $self->debug('using '.$class);
        } else {
          bless $self, 'Classes::Generic';
          $self->debug('using Classes::Generic');
        }
      }
    }
  }
  return $self;
}


package Classes::Generic;
our @ISA = qw(Classes::Device);
use strict;


sub init {
  my $self = shift;
  bless $self, 'Monitoring::GLPlugin::SNMP';
  $self->no_such_mode();
}

