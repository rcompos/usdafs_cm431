#!/etc/Tivoli/bin/perl
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
package date;

# The following defines the first day that the Gregorian calendar was used
# in the British Empire (Sep 14, 1752).  The previous day was Sep 2, 1752
# by the Julian Calendar.  The year began at March 25th before this date.

# rb 082098 Added mg* routines to help with the way we might calculate 
#           dates for week beginning and ending and a format that will 
#           return a date in mm/dd/yyyy format

$brit_jd = 2361222;
$mg_century = 1900;

sub main'jdate
# Usage:  ($month,$day,$year,$weekday) = &jdate($julian_day)
{
        local($jd) = @_;
        local($jdate_tmp);
        local($m,$d,$y,$wkday);

        warn("warning:  pre-dates British use of Gregorian calendar\n")
                if ($jd < $brit_jd);

        $wkday = ($jd + 1) % 7;       # calculate weekday (0=Sun,6=Sat)
        $jdate_tmp = $jd - 1721119;
        $y = int((4 * $jdate_tmp - 1)/146097);
        $jdate_tmp = 4 * $jdate_tmp - 1 - 146097 * $y;
        $d = int($jdate_tmp/4);
        $jdate_tmp = int((4 * $d + 3)/1461);
        $d = 4 * $d + 3 - 1461 * $jdate_tmp;
        $d = int(($d + 4)/4);
        $m = int((5 * $d - 3)/153);
        $d = 5 * $d - 3 - 153 * $m;
        $d = int(($d + 5) / 5);
        $y = 100 * $y + $jdate_tmp;
        if($m < 10) {
                $m += 3;
        } else {
                $m -= 9;
                ++$y;
        }
        ($m, $d, $y, $wkday);
}


sub main'jday
# Usage:  $julian_day = &jday($month,$day,$year)
{
        local($m,$d,$y) = @_;
        local($ya,$c);

		# Begin y2k correction - rb
		if ($y eq '') {
	        $y = (localtime(time))[5];

			if ($y < 70) {
				$y += 2000;
			} else {
				$y += 1900;
			}
		}

		# End y2k correction - rb

        if ($m > 2) {
                $m -= 3;
        } else {
                $m += 9;
                --$y;
        }
        $c = int($y/100);
        $ya = $y - (100 * $c);
        $jd =  int((146097 * $c) / 4) +
                   int((1461 * $ya) / 4) +
                   int((153 * $m + 2) / 5) +
                   $d + 1721119;
        warn("warning:  pre-dates British use of Gregorian calendar\n")
                if ($jd < $brit_jd);
        $jd;
}

sub main'is_jday
{
# Usage:  if (&is_jday($number)) { print "yep - looks like a jday"; }
        local($is_jday) = 0;
        $is_jday = 1 if ($_[0] > 1721119);
}

sub main'monthname
# Usage:  $month_name = &monthname($month_no)
{
        local($n,$m) = @_;
        local(@names) = ('January','February','March','April','May','June',
                         'July','August','September','October','November',
                         'December');
        if ($m ne '') {
                substr($names[$n-1],0,$m);
        } else {
                $names[$n-1];
        }
}

sub main'monthnum
# Usage:  $month_number = &monthnum($month_name)
{
        local($name) = @_;
        local(%names) = (
                'JAN',1,'FEB',2,'MAR',3,'APR',4,'MAY',5,'JUN',6,'JUL',7,'AUG',8,
                'SEP',9,'OCT',10,'NOV',11,'DEC',12);
        $name =~ tr/a-z/A-Z/;
        $name = substr($name,0,3);
        $names{$name};
}

sub main'weekday
# Usage:  $weekday_name = &weekday($weekday_number)
{
        local($wd, $format) = @_;
		local($name);

		$name = ("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")[$wd];

		if ($format ne "long") {
        	$name = substr($name,0,3);
		}
		$name;
}

sub main'today
# Usage:  $today_julian_day = &today()
{
        local(@today) = localtime(time);
        local($d) = $today[3];
        local($m) = $today[4];
        local($y) = $today[5];
        $m += 1;

		# Begin y2k correction - rb
		if ($y < 70) {
	        $y += 2000;
		} else {
			$y += 1900;
		}
		# End y2k correction - rb

        &main'jday($m,$d,$y);
}
        
sub main'yesterday
# Usage:  $yesterday_julian_day = &yesterday()
{
        &main'today() - 1;
}
        
sub main'tomorrow
# Usage:  $tomorrow_julian_day = &tomorrow()
{
        &main'today() + 1;
}
        
# Hourly Work Week Friday   to Thursday
# Staff  Work Week Saturday to Friday
sub main'mg_work_week {
	local($jd, $hs) = @_;
	local($week_beg, $week_end);
	local($m, $d, $y, $wd);

	($m, $d, $y, $wd) = &main'jdate($jd);

	if ($hs eq "H") {
		if 	  ($wd == 0) {$week_beg = $jd - 2; }	# Sunday
		elsif ($wd == 1) {$week_beg = $jd - 3; }	# Monday
		elsif ($wd == 2) {$week_beg = $jd - 4; }	# Tuesday
		elsif ($wd == 3) {$week_beg = $jd - 5; }	# Wednesday
		elsif ($wd == 4) {$week_beg = $jd - 6; }	# Thursday
		elsif ($wd == 5) {$week_beg = $jd;     }	# Friday
		elsif ($wd == 6) {$week_beg = $jd - 1; }	# Saturday
	} else {
		if 	  ($wd == 0) {$week_beg = $jd - 1; }	# Sunday
		elsif ($wd == 1) {$week_beg = $jd - 2; }	# Monday
		elsif ($wd == 2) {$week_beg = $jd - 3; }	# Tuesday
		elsif ($wd == 3) {$week_beg = $jd - 4; }	# Wednesday
		elsif ($wd == 4) {$week_beg = $jd - 5; }	# Thursday
		elsif ($wd == 5) {$week_beg = $jd - 6; }	# Friday
		elsif ($wd == 6) {$week_beg = $jd;     }	# Saturday
	}
	$week_end = $week_beg + 6;
	return($week_beg, $week_end);
}

sub main'mg_weekday {
	local($jd, $hs) = @_;
	local($m, $d, $y, $wd, $weekday);

	($m, $d, $y, $wd) = &main'jdate($jd);

	if ($hs eq "H") {
		if    ($wd == 0) { $weekday = 2; }
		elsif ($wd == 1) { $weekday = 3; }
		elsif ($wd == 2) { $weekday = 4; }
		elsif ($wd == 3) { $weekday = 5; }
		elsif ($wd == 4) { $weekday = 6; }
		elsif ($wd == 5) { $weekday = 0; }
		elsif ($wd == 6) { $weekday = 1; }
	} else {
		if    ($wd == 0) { $weekday = 1; }
		elsif ($wd == 1) { $weekday = 2; }
		elsif ($wd == 2) { $weekday = 3; }
		elsif ($wd == 3) { $weekday = 4; }
		elsif ($wd == 4) { $weekday = 5; }
		elsif ($wd == 5) { $weekday = 6; }
		elsif ($wd == 6) { $weekday = 0; }
	}
	($weekday);
}

sub main'mg_work_month {
# Usage ($month_begin, $month_end) = &mg_work_month($julian_day, $hs_flag)
	local($jd, $hs) = @_;
	local($month_beg, $month_end, $x);


	$month_beg = &main'mg_bom_julian($jd);
	$month_end = &main'mg_eom_julian($jd);
	
	($month_beg, $x) = &main'mg_work_week($month_beg, $hs);
	($x, $month_end) = &main'mg_work_week($month_end, $hs);

	return($month_beg, $month_end);
}

sub main'mg_week_beg
# Usage $week_beg_julian = &mg_week_beg($julian_day)
{
	local($jd) = @_;
	local($m, $d, $y, $wd);
	($m, $d, $y, $wd) = &main'jdate($jd);
	
	( &main'mg_week_end - 6  );
}

sub main'mg_week_end
# Usage $week_end_julian = &mg_week_end($julian_day);
{
	local($jd) = @_;
	local($m, $d, $y, $wd, $return_jd);
	($m, $d, $y, $wd) = &main'jdate($jd);
	
	if ($wd <= 5 ) {
		$return_jd = $jd + 5 - $wd;
	} else {
		$return_jd = $jd + 6;
	}

	(  $return_jd  );
}

sub main'mg_format_date 
# Usage $formatted_date = &mg_format_date($julian_day);
{
	local($jd,$format) = @_;
    local($m, $d, $y, $wd, $dt) = @_;

    ($m, $d, $y, $wd) = &main'jdate($jd);
	
	if ($format eq "mmddyyyy") {
    	$dt =  sprintf("%02d/%02d/%04d",$m, $d, $y);
	} elsif ($format eq "mmdd") {
    	$dt =  sprintf("%02d/%02d",$m, $d);
	} elsif ($format eq "ShortNames") {
		$dt = &main'monthname($m, 3) . ".  $d, $y"; 
	} elsif ($format eq "LongNames") {
		$dt = &main'monthname($m) . " $d, $y"; 
	} elsif ($format eq "DayLongNames") {
		$dt = &main'weekday($wd, 'long') . " " . &main'monthname($m) . " $d, $y"; 
	} else {
    	$dt =  sprintf("%02d/%02d/%04d",$m, $d, $y);
	}
    ($dt);
}

sub main'mg_bom_julian 
# Usage $beginning_of_month_julian = &mg_bom_julian($julian_date);
{
	local($in_julian) = @_;
	local($m,$d,$y,$wd,$bom_julian);

	($m,$d,$y,$wd) = &main'jdate($in_julian);
	
	$bom_julian = &main'jday($m, 1, $y);

	($bom_julian);
}

sub main'mg_eom_julian
# Usage $ending_of_month_julian = &mg_eom_julian($julian_date);
# To find the ending julian date of a month.  Find the first
# Day of the next month and subtract 1
{
	local($in_julian) = @_;
	local($m,$d,$y,$wd,$eom_julian);

	($m,$d,$y,$wd) = &main'jdate($in_julian);

	if ($m == 12) {
		$m = 1;
		$y++;
	} else {
		$m++;
	}
		
	$eom_julian = &main'jday($m, 1, $y);

	$eom_julian = $eom_julian - 1;

	($eom_julian);
}


1;

$future_days = 0;
$julian_today = &main'today;

if (@ARGV){

	if ($ARGV[0] =~ /\d+/){
		$future_days = $ARGV[0];
	}elsif ($ARGV[0] =~ /fri/i){

		($month,$day,$year,$weekday) = &main'jdate($julian_today);

		if ($weekday == 0) {
			$future_days = 5;
		}elsif ($weekday == 1) {
			$future_days = 4;
		}elsif ($weekday == 2) {
			$future_days = 3;
		}elsif ($weekday == 3) {
			$future_days = 2;
		}elsif ($weekday == 4) {
			$future_days = 1;
		}elsif ($weekday == 5) {
			$future_days;
		}elsif ($weekday == 6) {
			$future_days = 6;
		}
 
	}elsif ($ARGV[0] =~ /sat/i){

		($month,$day,$year,$weekday) = &main'jdate($julian_today);

		if ($weekday == 0) {
			$future_days = 6;
		}elsif ($weekday == 1) {
			$future_days = 5;
		}elsif ($weekday == 2) {
			$future_days = 4;
		}elsif ($weekday == 3) {
			$future_days = 3;
		}elsif ($weekday == 4) {
			$future_days = 2;
		}elsif ($weekday == 5) {
			$future_days = 1;
		}elsif ($weekday == 6) {
			$future_days = 0;
		}

	}

}

$schedule_date = $julian_today + $future_days;
($month,$day,$year,$weekday) = &main'jdate($schedule_date);
print "$month/$day/$year\n";
