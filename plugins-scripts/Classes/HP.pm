package Classes::HP;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if (ref($self) ne "Classes::HP") {
    $self->init();
  }
}

