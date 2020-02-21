package Classes::Dell::Datadomain::Component::CpuSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["systemstatss", "systemStatsTable", "Classes::Dell::Datadomain::Component::CpuSubsystem::SystemStats"],
  ]);
}

package Classes::Dell::Datadomain::Component::CpuSubsystem::SystemStats;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my ($self) = @_;
  $self->add_info(sprintf "avg cpu usage is %.2f (max %.2f)",
      $self->{cpuAvgPercentageBusy}, $self->{cpuMaxPercentageBusy});
  $self->add_thresholds(
      metric => 'cpu_usage',
      warning => 80,
      critical => 90,
  );
  $self->add_message($self->check_thresholds(
      metric => 'cpu_usage', value => $self->{cpuAvgPercentageBusy},
  ));
  $self->add_perfdata(
      label => 'cpu_usage',
      value => $self->{cpuAvgPercentageBusy},
      uom => '%',
  );
}
