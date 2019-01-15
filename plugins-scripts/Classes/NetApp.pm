package Classes::NetApp;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->{productname} =~ /NetApp/i) {
    bless $self, 'Classes::NetApp::Filer';
    $self->debug('using Classes::NetApp::Filer');
  }
  if (ref($self) ne "Classes::NetApp") {
    $self->init();
  }
}

