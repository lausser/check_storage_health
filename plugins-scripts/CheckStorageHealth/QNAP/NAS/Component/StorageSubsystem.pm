package CheckStorageHealth::QNAP::NAS::Component::StorageSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);

sub init {
  my ($self) = @_;
  $self->get_snmp_tables("NAS-MIB", [
    ["volumes", "systemVolumeTable", "CheckStorageHealth::QNAP::NAS::Component::StorageSubsystem::Volumes"],
  ]);
}

package CheckStorageHealth::QNAP::NAS::Component::StorageSubsystem::Volumes;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);

sub check {
  my ($self) = @_;

  $self->{sysVolumeTotalSize} =~ s/\s.*//;
  $self->{sysVolumeFreeSize} =~ s/\s.*//;
  my $free = $self->{sysVolumeFreeSize} / $self->{sysVolumeTotalSize} * 100;

  $self->add_info(sprintf "volume %s status is %s",
      $self->{sysVolumeDescr},
      $self->{sysVolumeStatus},
  );

  if (lc $self->{sysVolumeStatus} ne "ready") {
    $self->add_warning();
  } else {
    $self->add_ok();
  }

  $self->set_thresholds(
      metric => sprintf("volume_%s_free_pct", $self->{sysVolumeIndex}),
      warning => "10:",
      critical => "5:",
  );

  $self->add_message(
      $self->check_thresholds(
          metric => sprintf('volume_%s_free_pct', $self->{sysVolumeIndex}),
          value => $free
      ),
      sprintf("%.2f%% free space", $free)
  );

  $self->add_perfdata(
      label => sprintf("volume_%s_free_pct", $self->{sysVolumeIndex}),
      uom => "%",
      value => $free
  );

}


