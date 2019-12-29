package Classes::Dell;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if (ref($self) ne "Classes::Dell") {
    $self->init();
  }
}

