package CheckStorageHealth::NetApp;
our @ISA = qw(CheckStorageHealth::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->{productname} =~ /NetApp/i) {
    bless $self, 'CheckStorageHealth::NetApp::Filer';
    $self->debug('using CheckStorageHealth::NetApp::Filer');
  }
  if (ref($self) ne "CheckStorageHealth::NetApp") {
    $self->init();
  }
}

