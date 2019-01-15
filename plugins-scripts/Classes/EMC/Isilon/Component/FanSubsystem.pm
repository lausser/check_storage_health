package Classes::EMC::Isilon::Component::FanSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("ISILON-MIB", [
    ["fans", "fanTable", "Classes::EMC::Isilon::Component::FanSubsystem::Fan", undef, undef, "fanName"],
  ]);
}

package Classes::EMC::Isilon::Component::FanSubsystem::Fan;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub finish {
  my ($self) = @_;
  if ($self->{fanName} =~ /(.*)_speed/i) {
    $self->{name} = lc $1;
  } else {
    $self->{name} = lc $self->{fanName};
  }
}

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "%s is %drpm",
      $self->{fanName}, $self->{fanSpeed});
  $self->set_thresholds(
      metric => $self->{fanName},
      warning => "3000:9000",
      critical => "",
  );
  $self->add_message($self->check_thresholds(
      metric => $self->{fanName},
      value => $self->{fanSpeed},
  ));
  $self->add_perfdata(
      label => $self->{fanName},
      value => $self->{fanSpeed},
  );
}
