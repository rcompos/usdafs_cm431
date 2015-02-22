#!/usr/bin/sh
#
# This script is used to create the Profile Managers and Profiles for
# Windows and AIX systems.
#
# Modified for Inventory4
#
# MODIFIED : 2004-11-16 by Ron Compos
#            Integrated Inventory scripts into CM421 New Build
#


. /etc/Tivoli/setup_env.sh

########## Global Variables #######

LogPath=/usr/local/Tivoli/var/install
TMR_NAME=`wtmrname | cut -d. -f1`

# Get the Inventory Policy Region name.
# <reg>.apps.inv.pr
INV_APPS_PR=`wlookup -ar PolicyRegion | grep -i 'apps.inv' | cut -f1`

# <reg>.apps.inv
PM_PREFIX=`echo ${INV_APPS_PR} | cut -d'.' -f -3`

# <reg>.subs.pr
SUBS_PR=`wlookup -ar PolicyRegion | grep 'subs.pr' | cut -f1`

# <reg>.subs
SUBS_PM_PREFIX=`echo ${SUBS_PR} | cut -d'.' -f -2`

########### Subroutines ############

#working() {
#   echo ".\c";
#}

# find out where we are, we must be on the TMR

#echo "Working .\c"

Self=`objcall 0.0.0 self`
Dispatcher=`echo $Self | awk -F\. '{print $2}'`

if [ ${Dispatcher} -ne 1 ]
then
        echo "This script must be run from the TMR Server"
        exit 1
fi

if [ ! -d $LogPath ]
then
        mkdir $LogPath
        chmod 775 $LogPath
fi

# Build Profile Managers and Profiles
#working
echo "Building Profile Managers and Profiles in ${PM_PREFIX}..." >> ${LogPath}/crtinvpm.log
wcrtprfmgr \@PolicyRegion:${INV_APPS_PR} ${PM_PREFIX}.pm  >> ${LogPath}/crtinvpm.log 2>&1

########################################3
# 
# Create basic Inventory scan profiles


#working
#print "wcrtprf @ProfileManager:${PM_PREFIX}.pm InventoryConfig ${PM_PREFIX}.WIN_Scan\n"
#exit 0;


wcrtprf \@ProfileManager:${PM_PREFIX}.pm InventoryConfig ${PM_PREFIX}.WIN_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvglobal -e 600 -m Y -s Y -t FAIL -u REPLACE -w N @InventoryConfig:${PM_PREFIX}.WIN_Scan
wsetinvpchw -t Y -u Y -d N -s N @InventoryConfig:${PM_PREFIX}.WIN_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpcsw -r BOTH -s BOTH @InventoryConfig:${PM_PREFIX}.WIN_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpcfiles -e INCLUDE -f +"*.com" -f +"*.drv" -f +"*.exe" -f +"*.js" -f +"*.pif" -f +"*.scr" -f +"*.mtx"\
		   -f +"*.aum" -f +"*.bat" -f +"*.cmd" -f +"*.exp" -f +"*.fes" -f +"*.fmx" -f +"*.ini"\
		   -f +"*.int" -f +"*.nlm" -f +"*.isu" -f +"*.pgm" -f +"*.ocx" -f +"*.sig" -f +"*.plx"\
		   -f +"*.shs" -f +"*.reg" -f +"*.sys" -f +"*.sql" -f +"*.vbs" -f +"*.vbe"\
		-m +"useradd.mif" \
 \@InventoryConfig:${PM_PREFIX}.WIN_Scan >>${LogPath}/crtinvpm.log 2>&1
wsetinvunixhw -t N -u N @InventoryConfig:${PM_PREFIX}.WIN_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixsw -p NO -s NO @InventoryConfig:${PM_PREFIX}.WIN_Scan >> ${LogPath}/crtinvpm.log 2>&1


#working
wcrtprf \@ProfileManager:${PM_PREFIX}.pm InventoryConfig ${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1
wsetinvglobal -e 600 -m Y -s Y -t FAIL -u REPLACE -w N @InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly
wsetinvpchw -t N -u N -d N @InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpcsw -r NO -s NO @InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpcfiles -s /usr/local/Tivoli/scripts/inventory/ums-scn.bat\
	\@InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpcfiles -m +"C:/umativoli.mif" -m +"c:/umsinv.mif" \
	 \@InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixhw -t N -u N @InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixsw -p NO -s NO @InventoryConfig:${PM_PREFIX}.UMS.WIN_ScanOnly >> ${LogPath}/crtinvpm.log 2>&1


# Get all mif files from one inventoryconfig profile called WIN_GetMIFs
#working
wcrtprf \@ProfileManager:${PM_PREFIX}.pm InventoryConfig ${PM_PREFIX}.WIN_GetMIFs >> ${LogPath}/crtinvpm.log 2>&1
wsetinvglobal -e 600 -m Y -s Y -t FAIL -u REPLACE -w N @InventoryConfig:${PM_PREFIX}.WIN_GetMIFs
wsetinvpcfiles -m +"useradd.mif" -m +"C:/umativoli.mif" -m +"c:/umsinv.mif" \
	 \@InventoryConfig:${PM_PREFIX}.WIN_GetMIFs >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpchw -t N -u N -d N @InventoryConfig:${PM_PREFIX}.WIN_GetMIFs >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpcsw -r NO -s NO @InventoryConfig:${PM_PREFIX}.WIN_GetMIFs >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixhw -t N -u N @InventoryConfig:${PM_PREFIX}.WIN_GetMIFs >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixsw -p NO -s NO @InventoryConfig:${PM_PREFIX}.WIN_GetMIFs >> ${LogPath}/crtinvpm.log 2>&1


#working
wcrtprf \@ProfileManager:${PM_PREFIX}.pm InventoryConfig ${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvglobal -e 600 -m N -s Y -t FAIL -u REPLACE @InventoryConfig:${PM_PREFIX}.AIX_Scan
wsetinvunixhw -t Y -u Y @InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixsw -p BOTH -s BOTH @InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixfiles -t INCLUDE -d +"/dfs/local" -d +"/var/lpp" @InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixfiles -t EXCLUDE -d +"/usr/local/Tivoli" -d +"*/lib" -d +"*/css" -d +"*/cdrom" -d +"*/dev" \
			-d +"*/devices" -d +"*/etc" -d +"*/include" -d +"*/info" -d +"*/mail" -d +"*/man" \
			-d +"*/news" -d +"*/opt" -d +"/temp" -d +"/tmp" -d +"/recycler" \
	\@InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvunixfiles -m +"useradd.mif" @InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1
wsetinvpchw -t N -u N -d N -s N @InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1 
wsetinvpcsw -r NO -s NO @InventoryConfig:${PM_PREFIX}.AIX_Scan >> ${LogPath}/crtinvpm.log 2>&1

########################################3


# Subscribe Profile Manager for each region.
#working
echo "Subscribing Profile Manager for each region to ${PM_PREFIX}.pm ..." >> ${LogPath}/crtinvpm.log 2>&1
# ie <reg>.apps.inv.pm
for SUB in `wlookup -ar ProfileManager | grep -v dpm | grep ${TMR_NAME}.subs | cut -f1`
do
   wsub @ProfileManager:${PM_PREFIX}.pm @ProfileManager:${SUB}
done

# Note: These should already exist
#echo "Creating dataless profile managers in ${PM_PREFIX}..." >> ${LogPath}/crtinvpm.log 2>&1
#for PM_NAME in RollingScanAIX.dpm RollingScanWIN.dpm
## <reg>.subs.RollingScanAIX.dpm subscribed to <reg>.subs.pr
## <reg>.subs.RollingScanWIN.dpm subscribed to <reg>.subs.pr
#do
#  working
#  wcrtprfmgr \@PolicyRegion:${SUBS_PR} ${SUBS_PM_PREFIX}.${PM_NAME} >> ${LogPath}/crtinvpm.log 2>&1
#  wsetpm -d @ProfileManager:${SUBS_PM_PREFIX}.${PM_NAME} >> ${LogPath}/crtinvpm.log 2>&1
#done


exit 0
