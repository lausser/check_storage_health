package Classes::EMC;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->{productname} =~ /isilon/i) {
    bless $self, 'Classes::EMC::Isilon';
    $self->debug('using Classes::EMC::Isilon');
  }
  if (ref($self) ne "Classes::EMC") {
    $self->init();
  }
}

