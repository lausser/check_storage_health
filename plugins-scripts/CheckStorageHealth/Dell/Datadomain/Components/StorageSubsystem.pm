package CheckStorageHealth::Dell::Datadomain::Component::StorageSubsystem;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::Item';
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("DATA-DOMAIN-MIB", [
      ["filesystemspaces", "fileSystemSpaceTable", "CheckStorageHealth::Dell::Datadomain::Component::StorageSubsystem::FileSystemSpace", sub { return $self->filter_name(shift->{fileSystemResourceName}) }],
  ]);
}

package CheckStorageHealth::Dell::Datadomain::Component::StorageSubsystem::FileSystemSpace;
use parent -norequire, 'Monitoring::GLPlugin::SNMP::TableItem';
use strict;

sub check {
  my($self) = @_;
  my $name = $self->{fileSystemResourceName};
  my $free_pct = 100 - $self->{fileSystemPercentUsed};
  $self->override_opt("units", "%") if ! $self->opts->units;
  my $display_units = $self->opts->units eq "%" ? "GB" : $self->opts->units;
  my $display_free = $self->{fileSystemSpaceAvail} * 1024 * 1024 * 1024 * 8 /
      $self->number_of_bits($display_units);
  $self->add_info(sprintf "fs %s has %.2f%% free space (%.2f%s)",
      $name, $free_pct, $display_free, $display_units);

  if ($self->opts->units eq "%") {
    my $label = "fs_".$name."_free_pct";
    $self->set_thresholds(
        metric => $label,
        warning => "15:",
        critical => "10:",
    );
    $self->add_message($self->check_thresholds(
        metric => $label,
        value => $free_pct,
    ));
    $self->add_perfdata(
        label => $label,
        value => $free_pct,
        uom => "%",
    );
  } else {
    my $label = "fs_".$name."_free";
    $self->set_thresholds(
        metric => $label,
        warning => "15:",
        critical => "10:",
    );
    $self->add_message($self->check_thresholds(
        metric => $label,
        value => $display_free,
    ));
    $self->add_perfdata(
        label => $label,
        value => $display_free,
        uom => $self->opts->units,
    );
  }
}
