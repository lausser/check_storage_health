package Classes::Dell::Storagecenter::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my ($self) = @_;
  $self->get_snmp_objects("DELL-STORAGE-SC-MIB", qw(productIDDisplayName
      productIDSerialNumber productIDGlobalStatus));
  $self->init_subsystems([
      ["temperature_subsystem", "Classes::Dell::Storagecenter::Component::TemperatureSubsystem"],
      ["power_subsystem", "Classes::Dell::Storagecenter::Component::PowersupplySubsystem"],
      ["disk_subsystem", "Classes::Dell::Storagecenter::Component::DiskSubsystem"],
      ["fan_subsystem", "Classes::Dell::Storagecenter::Component::FanSubsystem"],
      ["node_subsystem", "Classes::Dell::Storagecenter::Component::NodeSubsystem"],
      ["alert_subsystem", "Classes::Dell::Storagecenter::Component::AlertSubsystem"],
  ]);
  return;
  $self->get_snmp_tables("DELL-STORAGE-SC-MIB", [
    ["controllers", "scCtlrTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["enclosures", "scEnclTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["voltages", "scCtlrVoltageTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["iomods", "scEnclIoModTable", "Monitoring::GLPlugin::SNMP::TableItem"],
  #nix#  ["alarms", "scEnclAlarmTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["folders", "scDiskFolderTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["volumes", "scVolumeTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["caches", "scCacheTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["scs", "scScTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["counters", "scObjCntTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    ["folderssu", "scDiskFolderSUTable", "Monitoring::GLPlugin::SNMP::TableItem"],
    #["alerts", "scAlertTable", "Monitoring::GLPlugin::SNMP::TableItem"],
  ]);

}



sub check {
  my ($self) = @_;
  $self->check_subsystems();
  if (! $self->opts->subsystem || $self->opts->subsystem eq "global") {
    $self->add_info(sprintf "global status is %s",
        $self->{productIDGlobalStatus});
    if ($self->{productIDGlobalStatus} eq "ok") {
      $self->add_ok();
    } elsif ($self->{productIDGlobalStatus} eq "critical" ||
        $self->{productIDGlobalStatus} eq "nonrecoverable") {
      $self->add_critical();
    } elsif ($self->{productIDGlobalStatus} eq "noncritical") {
      $self->add_warning();
    } else {
      $self->add_unknown();
    }
    $self->reduce_messages_short("environmental hardware working fine")
        if ! $self->opts->subsystem;
  }
}

sub dump {
  my ($self) = @_;
  $self->dump_subsystems();
  $self->SUPER::dump();
}

__END__
scCtlrTable
 scCtlrStatus

scDiskTable
 scDiskHealthy
 scDiskStatusMsg 'no status message' when scDiskStatus=up"

scEnclTable
  scEnclStatus
  scEnclStatusDescr

scCtlrFanTable
 scCtlrFanStatus
 scCtlrFanName
  --rpm

scCtlrPowerTable
 scCtlrPowerStatus

scCtlrVoltageTable
 scCtlrVoltageStatus

#scCtlrTempTable
# scCtlrTempStatus
# --monmax

scEnclFanTable
 scEnclFanStatus

scEnclPowerTable
 scEnclPowerStatus

scEnclIoModTable
 scEnclIoModStatus

#scEnclTempTable
# scEnclTempStatus
 
scEnclAlarmTable
 scEnclAlarmStatus

scDiskFolderTable
 scDiskFolderStatus

scVolumeTable
 scVolumeStatus

scServerTable
 scServerStatus

scCacheTable
 scCacheStatus

scScTable
 scScStatus

scUPSTable
 scUPSStatus
 scUPSBatLife
 scUPSStatusDescr

scObjCntTable
 scObjCntReplays
 
scDiskFolderSUTable
 scDiskFolderSUTotalSpace..

scSIDeviceStatus
scHWCompStatus
scHWCompState

scDiskConfigTable

scAlertTable
 scAlertStatus
 scAlertAcknowledged
 scAlertActive

