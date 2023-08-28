package CheckStorageHealth::Device;
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
        $self->rebless('CheckStorageHealth::NetApp');
      } elsif ($self->implements_mib('NETAPP-MIB')) {
        $self->rebless('CheckStorageHealth::NetApp');
      } elsif ($self->implements_mib('ISILON-MIB')) {
        $self->rebless('CheckStorageHealth::Dell::Isilon');
      } elsif ($self->implements_mib('DELL-STORAGE-SC-MIB')) {
        $self->rebless('CheckStorageHealth::Dell::Storagecenter');
      } elsif ($self->implements_mib('DATA-DOMAIN-MIB')) {
        $self->rebless('CheckStorageHealth::Dell::Datadomain');
      } elsif ($self->implements_mib('LEFTHAND-NETWORKS-NSM-INFO-MIB')) {
        $self->rebless('CheckStorageHealth::HP::Lefthand');
      } elsif ($self->implements_mib('SYNOLOGY-SYSTEM-MIB')) {
        $self->rebless('CheckStorageHealth::Synology');
      } elsif ($self->implements_mib('QTS-MIB') or
            $self->implements_mib('NAS-MIB')) {
        $self->rebless('CheckStorageHealth::QNAP');
      } elsif ($self->implements_mib('HOST-RESOURCES-MIB')) {
        $self->rebless('CheckStorageHealth::HOSTRESOURCESMIB');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          bless $self, $class;
          $self->debug('using '.$class);
        } else {
          bless $self, 'CheckStorageHealth::Generic';
          $self->debug('using CheckStorageHealth::Generic');
        }
      }
    }
  }
  return $self;
}


package CheckStorageHealth::Generic;
our @ISA = qw(CheckStorageHealth::Device);
use strict;


sub init {
  my $self = shift;
  bless $self, 'Monitoring::GLPlugin::SNMP';
  $self->no_such_mode();
}

