#!/usr/bin/perl
# $Header: /work/b272dev/in/lib/../../b272rcs/tooltiv.pl,v 1.2 2009/08/20 20:04:51 rcompos Exp $
#
# IBM USDA FS TMR Build v2.1
#
# library of functions for building Tivoli framework
# Call from Perl script like this:
#  unshift( @INC, "/usr/local/Tivoli/etc/script/lib" );
#  require "tooltiv.pl";
#

sub get_mn {
#
# Get the managed node label
#
    my @out = ();

    my $obj_no = vhx( "objcall 0.0.0 self", 3, 2 );
    my $mn_oid = vhx( "objcall $obj_no get_host_location", 3, 2 );
    my $mn_label = vhx( "idlcall $mn_oid _get_label", 3, 2 );
    $mn_label =~ s/^"(\S+)"$/$1/;
    push( @out, $mn_label );
    push( @out, $mn_oid );
    push( @out, $obj_no );
    if( wantarray() ) {
        return @out;
    } else {
        return $mn_label;
    }
}   # end sub get_mn


sub get_region {
#
# Returns the region
# Exits on error if the command-line -r argument doesnt match existing TMR region
# Initial install requires the -r argument to set the region name
# If the TMR has been previously installed, dont need the -r region value
#
    my $reg = shift;

    chomp( my $host = vhx( "hostname", 3, 1 ) );
    my $dir_db = "/usr/local/Tivoli/db/${host}.db";

    if( -d $dir_db ) {
        print "Tivoli database directory exists! $dir_db\n" if $dbug;
        print "Checking for existing TMR...\n" if $dbug;
        if( my $tmrname = vhx( "wtmrname", 3, 2 ) ) {  # TMR exists
            chomp $tmrname;
            ( my $reg_actual = $tmrname ) =~ s/^(\S+)\.pr$/$1/;
            print " " x $spc, "TMR region exists: $reg_actual\n" if $dbug;
            if( $reg && "$reg_actual" ne "$reg" ) {
                print "ERROR: TMR exists: $reg_actual\n";
                print "ERROR: Region name conflict: $reg\n";
                print "ERROR: Omit the '-r $reg' option and retry\n";
                exit 1;
            } else {  # Otherwise, continue with existing region
                $reg = $reg_actual;
            }
        } else {
            print "No response from oserv, continuing...\n" if $dbug;
        }
    } elsif( $reg ) {  # New build
        print "Region : $reg\n";
    } else {
        print "ERROR: Must specify region label!\n";
        exit 1;
    }
    print "\n" if $dbug;

    return( $reg );

}   # end sub get_region


sub rim_delete {
# Delete RIM object

    my $rim = shift;

    if( vhx( "wlookup -r RIM $rim", 3, 2 ) ) {
        #vhx( "wdel \@RIM:$rim", 3, 2 );
        vhx( "wdel \@RIM:$rim" );
    } else {
        print "Couldn't delete RIM object: doesn't exist: $rim\n";
    }

}   # end sub rim_delete


1; # DO NOT REMOVE

