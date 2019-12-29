package Classes::Dell::Isilon::Component::NodeSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("ISILON-MIB", qw(nodeName nodeHealth nodeType));
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s node %s has status %s",
      $self->{nodeType}, $self->{nodeName}, $self->{nodeHealth});
  if ($self->{nodeHealth} eq "ok") {
    $self->add_ok();
  } elsif ($self->{nodeHealth} eq "down") {
    $self->add_critical();
  } elsif ($self->{nodeHealth} eq "invalid") {
    $self->add_critical();
  } elsif ($self->{nodeHealth} eq "attn") {
    $self->add_warning();
  } else {
    $self->add_warning();
  }
}
