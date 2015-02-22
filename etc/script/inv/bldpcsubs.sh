#!/usr/bin/sh
#
# This script is used to all Endpoints to dataless Profile Managers so
# that they can be Inventory scanned over a two week period.
#
# v1.01 Dnguyen - 11/06/2002	added ep version check due to IY35885
#
# MODIFIED : 2004-11-16 by Ron Compos
#            Integrated Inventory scripts into CM421 New Build
#


# Get the Tivoli environment.
. /etc/Tivoli/setup_env.sh

############ Global Variables #############
ScriptsPath=/usr/local/Tivoli/etc/script/inv
dir_cfg=/usr/local/Tivoli/etc/cfg/inv
LogPath=/usr/local/Tivoli/var/log/inv

#cfg_new=$dir_cfg/new_cellmaster_ep.cfg

AIXEPs=$dir_cfg/aix_ep.tmp
WINEPs=$dir_cfg/windows_ep.tmp
#CellList=$dir_cfg/aix_cellmaster_ep.tmp
SvrList=$dir_cfg/aix_non_cellmaster_ep.tmp

if [ ! -d "$dir_cfg" ]; then
    echo "mkdir -m777 $dir_cfg"
    mkdir -m755 $dir_cfg
fi

if [ ! -d "$LogPath" ]; then
    echo "mkdir -m777 $LogPath"
    mkdir -m777 $LogPath
fi

#if [ ! -f "$cfg_new" ]; then
#    echo "File not found: $cfg_new"
#    exit 1
#fi

# Build a prefix for this TMR.
#SubPR=`wlookup -ar PolicyRegion | grep -i 'subs.pr' | cut -f1`
SubPR=`wlookup -ar PolicyRegion | grep 'subs.pr' | cut -f1`
SubPrefix=`echo "${SubPR}" | cut -d. -f -2`
RegPR=`echo "${SubPrefix}" | cut -d. -f -1`
#AppsPR=`wlookup -ar PolicyRegion | grep -i 'apps.inv.pr' | cut -f1`
AppsPR=`wlookup -ar PolicyRegion | grep 'apps.inv.pr' | cut -f1`
AppsPrefix=`echo "${AppsPR}" | cut -d. -f -3`

wep ls -i label,interp | grep aix4 | cut -f1 -d , >$AIXEPs
wep ls -i label,version,interp |grep \,9 | grep \,w | cut -f1 -d , >$WINEPs
#cat ${cfg_new} | grep 0contact | cut -f1 -d " " >$CellList
#cat ${cfg_new} | grep 1contact | cut -f1 -d " " >$SvrList

CNT=0

# Unsubscribe endpoints from all Inventory subscription list
#
	$ScriptsPath/bhunsub.sh ${RegPR}.subs.AIX_All.dpm 
	wunsub -a \@ProfileManager:${RegPR}.subs.AIX_All.dpm 
#	$ScriptsPath/bhunsub.sh ${RegPR}.subs.Auto_Scan_AIX_CellMaster.dpm 
#	wunsub -a \@ProfileManager:${RegPR}.subs.Auto_Scan_AIX_CellMaster.dpm 
#	$ScriptsPath/bhunsub.sh ${RegPR}.subs.Auto_Scan_AIX.dpm 
#	wunsub -a \@ProfileManager:${RegPR}.subs.Auto_Scan_AIX.dpm 


#for CNT in 1 2 3 4 5 6 7 8 9
#do
#	$ScriptsPath/bhunsub.sh ${RegPR}.subs.Auto_Scan_WIN_Day${CNT}.dpm 
#   	wunsub -a \@ProfileManager:${RegPR}.subs.Auto_Scan_WIN_Day${CNT}.dpm 
#
#done
#echo "Finished Unsubscribing endpoints from all Inventory subscription list"


# Subscribe all AIX servers to the all AIX Profile Manager
#
for ep in `cat $AIXEPs`
do
#	wsub \@ProfileManager:${RegPR}.subs.Auto_Scan_AIX.dpm \@Endpoint:$ep
	wsub \@ProfileManager:${RegPR}.subs.AIX_All.dpm \@Endpoint:$ep
done
echo "Finished subscribing AIX"



## Subscribe all Windows endpoints to one of the 9 daily Profile Manager
##
#for pc in `cat $WINEPs`
#do
#     CNT=`expr ${CNT} + 1`
#     if [ ${CNT} -eq 10 ] 
#     then 
#		CNT=1
#     fi
#     wsub \@ProfileManager:${RegPR}.subs.Auto_Scan_WIN_Day${CNT}.dpm \@Endpoint:$pc
#done
#echo "Finished subscribing Windows"


echo "Build Subscription List Complete!"
exit 0
