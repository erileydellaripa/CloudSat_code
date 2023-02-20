#!/usr/bin/perl
#
#  This routine checks the files at the cloudsat site and determines which
#  files have not already been brought in.  
#  
#  Jan 2007 Cristian Mitrescu - several modifications
# adapted from Kim Richardson - NRL Monterey

print "Running cloudsat_ftp.plx script\n";

use Net::FTP;
use Sys::Hostname;
use File::Basename;


$box = hostname();  #  Find which box we are working on

#
#  Setup the constants
#
$remotehost = "ftp1.cloudsat.cira.colostate.edu";
$remotedir = "ECMWF-AUX.R04/";
$cloudsatdir = "/Users/mapesgroup/CLOUDSAT/ECMWF-AUX.R04";   #  where to store them locally
                                                     #  see below how to make separate directories
#
#  Open the connection to cloudsat
#  Change the Debug to 0 after we are sure of everything.
#
print "Open ftp connection to $remotehost\n";
$ftp = Net::FTP->new($remotehost,
                      Timeout => 99999,
                      Passive => 1,
                      Debug => 0) or die "Can't connect: $@\n";

$ftp->login('mapes','dd887sa')  or die "Couldn't login\n";

#  1 way to get the julday - using present day!
#($sec, $min, $hour, $day, $month, $year, $wday, $jday, $isdst) = localtime();
#$month = $month+1;
#$year = 1900 + $year;
#$jday = $jday + 1;
#$jday_start= $jday;
#$jday_end = $jday;
#print "Time  ${hour}:${min}:${sec} $year $month $day $jday\n";
#.............................................................

# 2-nd way to get the data - specify your own julday range
$year = 2010;
$jday_start= 63; #have days preceeding this on bluecloud
$jday_end = 181; 
#........................................

$ftp->cwd("$remotedir")
    or die "Cannot change working directory ", $ftp->message;

for ($step = $jday_start;$step <= $jday_end;$step++) {
$jday = $step;
if($jday < 100) {$jday = "0$jday"; }
if($jday < 10) {$jday = "0$jday"; }

      $wherefrom = "${year}/${jday}/";
      $ftp->cwd("$wherefrom") 
#	  or die "Cannot change working directory ", $ftp->message; 
	  or print "Cannot change working directory ", $ftp->message; 
      @remote_files = $ftp->dir("*.zip");  # this type only
       print "@remote_files\n";

      $k = length($remote_files[0]);
      if($k ne 0) {
           print "GET THIS DATE -- JULDAY $jday\n";
           $localdir = "${cloudsatdir}";
#          this creates a local dir:  year/jday   -  if you don't want it, comment out the next 4 lines!!!
#          $localdir = "${cloudsatdir}${year}";
#          if (! -e $localdir) { mkdir($localdir,0775); }          #  make local year directory
#          $localdir = "${localdir}/${jday}";
#          if (! -e $localdir) { mkdir($localdir,0775); }          #  make local jday directory

          foreach $file (@remote_files) {
             ($permissions,$one,$userid,$usergroup,$filesize,$month,$day,$fn_year,$fn) =
             split(/\s+/,$file);
#            print "remote file: $fn\n";
            @splitname = split(".zip",$fn);
            $localfile = $splitname[0];
            $localfilezip = "${localdir}/${fn}";
            $localfile = "${localdir}/${localfile}";
#              if (!( `ls -1 ${localfile}*`)) {   # this line ensures that you don't overwrite existing data
                                                 # comment out if you want to overwrite (or just delete those files manually)
                print "getting: $localfilezip\n";
                $ftp->binary;
                $ftp->get($fn,$localfilezip);
#              }   # end of - this line ensures that you don't overwrite existing data
          }  # end getting a particular jday
      } else {
         print "NOT AVAILABLE -- JULDAY $jday\n";
      }

      $wherefrom = "../../";
      $ftp->cwd("$wherefrom") 
	  or print "Cannot change working directory ", $ftp->message;

}  # end step
$ftp->quit();

