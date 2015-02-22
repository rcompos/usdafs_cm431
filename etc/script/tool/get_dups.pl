#!/usr/bin/perl


# Script to find and print duplicate Tivoli endpoints
# so that they can be repaired.
# REQUIRES PERL 5
# Author = Don Bailey
# Modified by Don Whitfield....it's the Don show.

@EpList = `wlookup -aLr Endpoint | sort`;
chomp (@EpList);

foreach (@EpList){

	s/\s+//;

	next if (/\.\d+$/);

	$ep = $_;
	@DupPtr = ();
	@duplicates = ();
	@duplicates = grep (/^$ep/, @EpList);


	if ($#duplicates > 0){

		foreach $dup (@duplicates){
			print "$dup\n";
		}

		print "=" x 40 . "\n";

	}

}


