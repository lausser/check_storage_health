package CheckStorageHealth::Dell;
our @ISA = qw(CheckStorageHealth::Device);
use strict;

sub init {
  my $self = shift;
  if (ref($self) ne "CheckStorageHealth::Dell") {
    $self->init();
  }
}

