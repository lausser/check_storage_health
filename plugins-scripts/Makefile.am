libexec_SCRIPTS=check_storage_health
GL_MODULES=\
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline/Extraopts.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline/Getopt.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Commandline.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/Item.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/TableItem.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/CSF.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/Item.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/TableItem.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/DATADOMAINMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/DELLSTORAGESCMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/ISILONMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/MIB2MIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/NETAPPMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/SNMPV2TCV1MIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/UCDSNMPMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMCLUSTERINGMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMDNSMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMINFOMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMNETWORKMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMNOTIFICATIONMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMNTPMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMSECURITYMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMSTATUSMIB.pm \
  ../GLPlugin/lib/Monitoring/GLPlugin/SNMP/MibsAndOids/LEFTHANDNETWORKSNSMSTORAGEMIB.pm

EXTRA_MODULES=\
  Classes/NetApp/Filer/Component/AggregateSubsystem.pm \
  Classes/NetApp/Filer/Component/VolumeSubsystem.pm \
  Classes/NetApp/Filer/Component/PlexSubsystem.pm \
  Classes/NetApp/Filer/Component/DiskSubsystem.pm \
  Classes/NetApp/Filer/Component/CpuSubsystem.pm \
  Classes/NetApp/Filer.pm \
  Classes/NetApp.pm \
  Classes/Dell/Isilon/Component/EnvironmentalSubsystem.pm \
  Classes/Dell/Isilon/Component/PowersensorSubsystem.pm \
  Classes/Dell/Isilon/Component/TemperatureSubsystem.pm \
  Classes/Dell/Isilon/Component/FanSubsystem.pm \
  Classes/Dell/Isilon/Component/DiskSubsystem.pm \
  Classes/Dell/Isilon/Component/NodeSubsystem.pm \
  Classes/Dell/Isilon/Component/ClusterSubsystem.pm \
  Classes/Dell/Isilon/Component/CpuSubsystem.pm \
  Classes/Dell/Isilon/Component/StorageSubsystem.pm \
  Classes/Dell/Isilon/Component/SnapshotSubsystem.pm \
  Classes/Dell/Isilon/Component/QuotaSubsystem.pm \
  Classes/Dell/Isilon/Component/NetworkSubsystem.pm \
  Classes/Dell/Isilon.pm \
  Classes/Dell/Storagecenter/Component/AlertSubsystem.pm \
  Classes/Dell/Storagecenter/Component/NodeSubsystem.pm \
  Classes/Dell/Storagecenter/Component/FanSubsystem.pm \
  Classes/Dell/Storagecenter/Component/DiskSubsystem.pm \
  Classes/Dell/Storagecenter/Component/PowersupplySubsystem.pm \
  Classes/Dell/Storagecenter/Component/TemperatureSubsystem.pm \
  Classes/Dell/Storagecenter/Component/EnvironmentalSubsystem.pm \
  Classes/Dell/Storagecenter.pm \
  Classes/Dell/Datadomain/Components/CpuSubsystem.pm \
  Classes/Dell/Datadomain/Components/EnvironmentalSubsystem.pm \
  Classes/Dell/Datadomain/Components/AlertSubsystem.pm \
  Classes/Dell/Datadomain/Components/DiskSubsystem.pm \
  Classes/Dell/Datadomain/Components/FanSubsystem.pm \
  Classes/Dell/Datadomain/Components/PowersupplySubsystem.pm \
  Classes/Dell/Datadomain/Components/TemperatureSubsystem.pm \
  Classes/Dell/Datadomain.pm \
  Classes/Dell.pm \
  Classes/HP/Lefthand/Component/StorageSubsystem.pm \
  Classes/HP/Lefthand/Component/ClusterSubsystem.pm \
  Classes/HP/Lefthand/Component/RaidSubsystem.pm \
  Classes/HP/Lefthand/Component/DiskSubsystem.pm \
  Classes/HP/Lefthand/Component/EnvironmentalSubsystem.pm \
  Classes/HP/Lefthand/Component/CacheSubsystem.pm \
  Classes/HP/Lefthand/Component/FanSubsystem.pm \
  Classes/HP/Lefthand/Component/PowersupplySubsystem.pm \
  Classes/HP/Lefthand/Component/TemperatureSubsystem.pm \
  Classes/HP/Lefthand.pm \
  Classes/HP.pm \
  Classes/UCDMIB/Components/CpuSubsystem.pm \
  Classes/UCDMIB/Components/MemSubsystem.pm \
  Classes/Device.pm

SED=/bin/sed
GREP=/bin/grep
CAT=/bin/cat
ECHO=/bin/echo
if DISABLE_STANDALONE
STANDALONE = no
else
STANDALONE = yes
endif

SUFFIXES = .pl .pm .sh

VPATH=$(top_srcdir) $(top_srcdir)/plugins-scripts $(top_srcdir)/plugins-scripts/t

EXTRA_DIST=$(libexec_SCRIPTS).pl $(EXTRA_MODULES) $(GL_MODULES)

CLEANFILES=$(libexec_SCRIPTS)

AM_INSTALL_PROGRAM_FLAGS=@INSTALL_OPTS@

.pm :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

.pl :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

.sh :
	$(AWK) -f ./subst $< > $@
	chmod +x $@

$(libexec_SCRIPTS) : $(EXTRA_DIST)
	$(ECHO) "#! #PERL# -w" | $(AWK) -f ./subst > $@
	$(ECHO) "# nagios: -epn" >> $@
	$(ECHO) >> $@
	if [ "${STANDALONE}" == "yes" ]; then \
		$(ECHO) i am standalone; \
		for m in ${GL_MODULES}; do \
			$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(AWK) -f ./subst >> $@; \
		done \
	fi
	for m in ${EXTRA_MODULES}; do \
		$(SED) -e 's/^1;//g' < $$m | $(SED) -e '/^__END__/,$$d' | $(AWK) -f ./subst >> $@; \
	done
	$(ECHO) "package main;" >> $@
	$(CAT) $(libexec_SCRIPTS).pl | $(AWK) -f ./subst >> $@
	chmod +x $@

