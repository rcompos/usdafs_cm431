#!/usr/bin/perl
# $Header: /work/b272dev/in/lib/../../b272rcs/tool.pl,v 1.3 2009/08/20 20:04:07 rcompos Exp $
#
# IBM USDA FS TMR Build v2.1
#
# Library of general functions for building Tivoli 
# Call from Perl script like this:
#  unshift( @INC, "/usr/local/Tivoli/etc/script/lib" );
#  require "tool.pl";
#

sub vhx {
    #
    # Very Handy eXecuter
    # usage: vhx( $cmd, $exec, $bye )
    # where $cmd : Command to execute
    #       $exec : execute behavior
    #              where  0 = Print both command and output
    #                     1 = Print command
    #                     2 = Print output
    #                     3 = No print
    #                     4 = Print command only, No execute
    #       $bye : Exit behavior
    #              where  0 = Warn on failure
    #                     1 = Exit on failure
    #                     2 = No warn on failure
    #

    my $command = shift;
    my $exec = shift;
    my $bye = shift;
    if( ! defined $bye  ) {  $bye = 0 };
    if( ! defined $exec ) { $exec = 0 };
    my @out = ();
    if( $dbug ) {
        if( $exec == 4 ) { $exec = 4; $bye = 0 }
        else { $exec = 0; $bye = 0 }
    }

    $spc = $spc ? $spc : 4;
    #print "$0: \$spc: $spc\n" if $dbug;

    print "$command\n" if( ! $exec || $exec == 1 || $exec == 4 );

    unless( $exec == 4 ) {  # No execute, print command only

        if( $bye == 2 ) {
            open( CMD, "$command 2>/dev/null|" ) or die "FAILED: $command: $!";
        } else {
            open( CMD, "$command|" ) or die "FAILED: $command: $!";
        }

        while( <CMD> ) {
            print " " x $spc, "$_" if( ! $exec || $exec == 2 );
            push( @out, $_ );
        }
        close( CMD );

        $xs = $?;

        if( $xs ) {
            if( $bye == 0 || $bye == 1 ) {
                if( ! $exec || $exec == 1 ) {
                    print STDERR " " x $spc, "Failed: ";
                } else {
                    print STDERR " " x $spc, "Failed: $command\n";
                }
                print STDERR " " x $spc, "Status: ", $xs >> 8, "\n";
            }
            if( $bye == 1 ) { exit 1 };
        }


        #print "\n" if( ! $exec || $exec == 2 );

        if( wantarray() ) {
            return @out;
        } else {
            my $string;
            for( @out ) { $string .= $_ }
            return $string;
        }

    }

}   # end sub vhx


sub compare_list {
#
# Compare two lists and return the elements in the first but not the second
# The input to this subroutine must be two array references
#

    my $one = shift;
    my $two = shift;
    my %seen;
    my @one_only;
    my $sub_name = "compare_list";
    my $me = (caller(0))[3];
    $me =~ s/^main:://g;

    if( $dbug ) { 
        for( @$one ) { print "${me}() < $_\n" }
        for( @$two ) { print "${me}() > $_\n" }
    }

    @seen{ @$two } = ();
    for( @$one ) { push( @one_only, $_ ) unless exists $seen{ $_ } }

    return @one_only;

}   # end sub compare_list


sub confirm {
#
# Prompt user for confirmation
#
    my $force = shift;

    unless( $force ) {
        print "$_\n" for( @_ );
        print "\nContinue? (yes/no) ";
        my $in = <STDIN>;
        chomp $in;
        unless( lc $in eq "yes" ){ print "Cancelled.\n"; exit 0 }
    }
}   # end sub confirm


sub get_pass {
    my $pw    = shift;
    unless( $pw ) {
        my $got_pw = 1;
        until( ! $got_pw ) {
            if( $got_pw > 3 ) { print "Try again later\n"; exit 1 }
            vhx( "stty -echo", 3, 2 );
            print "\nroot\'s password: ";
            $pw = <STDIN>;
            chomp $pw;
            my $pw_old = $pw;
            print "\nroot\'s password again: ";
            $pw = <STDIN>;
            chomp $pw;
            vhx( "stty echo", 3, 2 );
            if( $pw ne $pw_old ) {
                print "\nPasswords don't match!\n";
            } elsif( ! $pw ) {
                print "\nBlank password!\n";
            }
            $got_pw++;
            #if( $pw eq $pw_old && $pw ) { print "\n"; $got_pw = 0 }
            if( $pw eq $pw_old && $pw ) { print "\n"; return $pw }
        }
    }

}   # end sub get_pass



sub runtime {
    #
    # Calculate run-time
    #
    my $time_zero = shift;
    my $end_time = time();
    my $run_time = $end_time - $time_zero;

    my( $hour, $min, $sec );
    if( $run_time >= 3600 ) {
        $hour = int $run_time / 3600;
        $run_time = int $run_time % 3600;
    } else { $hour = 0; }

    if( $run_time >= 60 ) {
        $min = int $run_time/ 60;
        $run_time = int $run_time % 60;
    } else { $min = 0; }

    $sec = $run_time;
    return( $hour, $min, $sec );

}   # end sub runtime


sub title {
#
# Adds lines of dashes on top and bottom of string
# title( $str, $pad, $offset );
# 

    my $str = shift;
    my $pad = shift;
    my $offset = shift;

    unless( defined $pad ) { $pad = 6 }
    unless( defined $offset ) { $offset = 0 }

    print "\n";
    print " " x $offset, "-" x ( length( $str ) + $pad ), "\n";
    print " " x $offset, " " x int( $pad / 2 ), $str, "\n";
    print " " x $offset, "-" x ( length( $str ) + $pad ), "\n";

}   # end sub title


sub setup_tivoli_env {
    my @Value = `. /etc/Tivoli/setup_env.sh; env`;
    chomp @Value;
    for my $Element ( @Value ) {
        my( $ElementKey, $ElementVal ) = split ( /=/, $Element );
        $ENV{$ElementKey} = $ElementVal;
    }
}  # end sub setup_tivoli_env


sub sleepy {
    my $count = shift;
    print "Sleeping $count seconds ";
    for( 1 .. $count ) {
        print ".";
        sleep 1;
    }
    print "\n";
}

##################
1; # DO NOT REMOVE
##################

