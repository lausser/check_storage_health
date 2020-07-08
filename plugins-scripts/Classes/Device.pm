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
        $self->rebless('Classes::NetApp');
      } elsif ($self->implements_mib('NETAPP-MIB')) {
        $self->rebless('Classes::NetApp');
      } elsif ($self->implements_mib('ISILON-MIB')) {
        $self->rebless('Classes::Dell::Isilon');
      } elsif ($self->implements_mib('DELL-STORAGE-SC-MIB')) {
        $self->rebless('Classes::Dell::Storagecenter');
      } elsif ($self->implements_mib('DATA-DOMAIN-MIB')) {
        $self->rebless('Classes::Dell::Datadomain');
      } elsif ($self->implements_mib('LEFTHAND-NETWORKS-NSM-INFO-MIB')) {
        $self->rebless('Classes::HP::Lefthand');
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

