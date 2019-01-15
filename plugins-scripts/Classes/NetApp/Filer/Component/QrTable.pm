package Classes::NetApp::Filer::Component::QrSubsystem;
our @ISA = qw(Classes::NetApp::Device);

use strict;
use constant { OK => 0, WARNING => 1, CRITICAL => 2, UNKNOWN => 3 };

sub init {
  my $self = shift;
  $self->get_snmp_tables("NETAPP-APPLIANCE-MIB", [
      ["qrs", "qrTable", "Classes::NetApp::Filer::Component::QrSubsystem::Qr"],
  ]);
}


sub check {
  my $self = shift;
  foreach (@{$self->{qrs}}) {
    $_->check();
  }
}

sub dump {
  my $self = shift;
  printf "[QRS]\n";
  foreach (@{$self->{qrs}}) {
    $_->dump();
  }
}

sub check {
  my $self = shift;
  if ($self->{wtWebGraphThermoBaroDiagErrorCount}) {
    $self->add_message(CRITICAL,
        sprintf "diag error count is %d (%s)",
        $self->{wtWebGraphThermoBaroDiagErrorCount},
        $self->{wtWebGraphThermoBaroDiagErrorMessage});
  } else {
    $self->add_message(OK, "environmental hardware working fine");
  }
}



