#!/usr/bin/sh
#

#
# (C) COPYRIGHT International Business Machines Corp. 1996
# All Rights Reserved
# Licensed Materials - Property of IBM
# IBM Confidential Information
#
# US Goverment Users Restricted Rights - Use, duplication or
# disclosure restricted by USDA Forest Service Contract with
# IBM Corp. (contract no. GS00K94ALD0001)
#

# This script is used to all Endpoints to dataless Profile Managers so
# that they can be Inventory scanned over a two week period.
#
# Get the Tivoli environment.
. /etc/Tivoli/setup_env.sh

############ Global Variables #############
ScriptsPath=/usr/local/Tivoli/etc/script/inv
LogPath=/usr/local/Tivoli/var/install



# assign command line arguments to variables

PMlabel=$1

oid=`wlookup -r ProfileManager $PMlabel`

#idlattr -tsv $oid subscribers TMF_CCMS::subscriber_list < $ScriptsPath/unsub.in
idlattr -tsv $oid subscribers TMF_CCMS::subscriber_list < $ScriptsPath/unsub.in
#idlattr -tsv $oid subscribers TMF_CCMS::subscriber_list { 0 }

exit 0
