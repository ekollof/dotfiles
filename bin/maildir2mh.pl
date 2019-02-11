#!/usr/bin/perl
# This should generate an MH hard linked copy of a maildir
# including generating the sylpheed_mark file
use File::stat;
use Getopt::Std;

$maildir = "$ENV{HOME}/Maildir/";
$mhdir = "$ENV{HOME}/Mail/";
$debug = 0;
$version = 1.4;
$date = 20100221;
our($opt_v, $opt_q, $opt_h, $opt_f, $opt_d, $opt_i, $opt_o, $opt_p);

$Getopt::Std::STANDARD_HELP_VERSION="TRUE";

# This is called if a help request is made
sub main::HELP_MESSAGE {
    print "maildir2mh will convert a Maildir format into a linked\n";
    print "           MH directory with a sylpheed mark file. By default\n";
    print "           it just sets up the most commonly updated folders.\n";
    print "           It has the following optional arguments:\n";
    print "             -d           Debug mode on\n";
    print "             -q           Quick mode - no MH sort performed\n";
    print "             -f           Full mode - set up all archived directories\n";   
    print "             -i maildir   Overide default maildir fullpath\n";
    print "             -o mhdir     Overide default MH fullpath\n";
    print "             -p           Preserve the existing MH dir\n";
    print "             -v --version Print the version\n";
    print "             -h --help    Print the usage information\n";
}

my %folderslist;
my %trashfolder;
my %emails;
my %trashemails;
my %emailtags;
my %emaildates;
my %trashemaildates;
my %mhsize;

if (getopts('dvhfpqi:o:')) { 
    if ($opt_d) {
 print "Debug mode on\n";
 $debug = 1;
        print "Maildir location: $maildir\n";
 print "     MH location: $mhdir\n";
    } else {
 $debug = 0;
    }      
    if ($opt_v) {
        print "Version: $version ($date)\n";
        exit 0;
    }
    if ($opt_h) {
        HELP_MESSAGE();
        exit 0;
    }
    if ($opt_f) {
        if ($debug) {print "Complete folder conversion";}
 print "Modify the folderslist - then remove this line\n";exit 1;
#       Edit the array below for your own setup - these are the
#       full list of folders to be linked if the option -f is chosen
 %folderslist = (
     './'                    => 'inbox/',
     '.archive/'             => 'archive/',
     '.archive.2000/'        => 'archive/2001/',
     '.archive.2001/'        => 'archive/2001/',
     '.archive.2002/'        => 'archive/2002/',
     '.archive.2003/'        => 'archive/2003/',
     '.archive.2004/'        => 'archive/2004/',
     '.archive.2005/'        => 'archive/2005/',
     '.archive.2006/'        => 'archive/2006/',
     '.archive.2007/'        => 'archive/2007/',
     '.archive.2008/'        => 'archive/2008/',
     '.archive.Sent/'        => 'archive/Sent/',
     '.archive.Sent.2007/'   => 'archive/Sent/2007/',
     '.archive.Sent.2008/'   => 'archive/Sent/2008/',
     '.archive.Sent.bf2006/' => 'archive/Sent/bf2006/',
     '.condmat/'             => 'condmat/',
     '.Drafts/'              => 'draft/',
     '.Old/'                 => 'Old/',
     '.spam/'                => 'spam/',
     '.Sent/'                => 'sent/',
     );
    } else {
 print "Modify the folderslist - then remove this line\n";exit 1;
#       Edit the array below for your own setup - these are the default
#       folders to be linked
 %folderslist = (
     './'                    => 'inbox/',
     '.condmat/'             => 'condmat/',
     '.Drafts/'              => 'draft/',
     '.spam/'                => 'spam/',
     '.Sent/'                => 'sent/',
 );
    }
    if ($opt_q) {
        if ($debug) {print "Quick mode - no sorting\n";}
    }
    if ($opt_p) {
        if ($debug) {print "Preserving the existings MH files\n";}
    }
    if ($opt_i) {
 $maildir = $opt_i;
 print "Overide - maildir is $maildir\n";
    }
    if ($opt_o) {
 $mhdir = $opt_o;
 print "Overide - MHdir is $mhdir\n";
    }

} else {
    HELP_MESSAGE();
    exit 1;
}

print "Modify the trashfolder - then remove this line\n";exit 1;
#       Edit the array below for your own setup - this is the location
#       of the folder for deleted email

%trashfolder = (
     '.Trash/'               => 'trash/',
            );
# First prepare the trash folder
my ($key, $folder) = %trashfolder ;
$cwd = $mhdir . $folder ;
$trashdir = $cwd;
%trashemails = ();
%emailtags = ();
%trashmaildates = ();
$trashsize = 0;
# $trashcount = 1;
# First ensure that the trash folder is empty - or preserved
if (-d $cwd) {   # The folder exists
    if ($debug) {print "$cwd exists\n";}
    opendir(DIR, $cwd) or die "Can't open $cwd: $!";
    $filecount = 0;
    while( defined ($file = readdir DIR) ) {
 $_ = $file ;
 if ((/^(\d*)$/) && (-f $cwd . $file)) {
     $filecount++;
     if ($opt_p) { # find the maximum filename
  if ($trashsize < $1) {$trashsize = $1;}
     } else {      # delete existing files
  if ($debug) {print "Deleting: $file\n";}
  unlink($cwd . $file) || print "$cwd$file: $!\n";
     }
 }
 if (-e $cwd . ".sylpheed_mark") {unlink($cwd . ".sylpheed_mark");}
 unless ($opt_p) {
     if (-e $cwd . ".sylpheed_cache") {unlink($cwd . ".sylpheed_cache");}
        }
    }    
    closedir(DIR);
    if (($opt_p) && ($filecount ne $trashsize)) { # sanity check
 print "File numbers in Trash are not contiguous - do not attempt to preserve MH directory (rerun without -p)\n";
 exit 1;
    }
} else {
    if ($debug) {print "$cwd does not exist\n";}
    mkdir("$cwd", 0700); # create the directory 
}
# Now go through each of the other maildirs
foreach $key (sort { $folderslist{$a} cmp $folderslist{$b} } (keys(%folderslist)) ) {  # This will go through the list of folders in alphabetical order
    $cwd = $mhdir . $folderslist{$key} ;
    $mhsize{$key} = 0;
    $filecount = 0;
       # First ensure that the MH folder is empty 
       # - or find max file name if preserving
    if (-d $cwd) {   # The folder exists
 if ($debug) {print "$cwd exists\n";}
 opendir(DIR, $cwd) or die "Can't open $cwd: $!";
 while( defined ($file = readdir DIR) ) {
     $_ = $file ;
     if ((/^(\d*)$/) && (-f $cwd . $file)) {
  $filecount++;
  if ($opt_p) {
      if ($mhsize{$key} < $1) {$mhsize{$key} = $1;}
  } else {
      if ($debug) {print "Deleting: $file\n";}
      unlink($cwd . $file) || print "$cwd$file: $!\n";
  }
     }
     if (-e $cwd . ".sylpheed_mark") {unlink($cwd . ".sylpheed_mark");}
            unless ($opt_p) {
  if (-e $cwd . ".sylpheed_cache") {unlink($cwd . ".sylpheed_cache");}
     }
 }    
 closedir(DIR);
 if (($opt_p) && ($filecount ne $mhsize{$key})) { # sanity check
     print "File numbers in $key are not contiguous - do not attempt to preserve MH directory (rerun without -p)\n";
     exit 1;
 }
    } else {
 if ($debug) {print "$cwd does not exist\n";}
 mkdir("$cwd", 0700); # create the directory 
    }
    # Now accumulate all the emails in the Maildir
    %emails = ();
    %emaildates = ();
#    $mhcount = 1;
    @maildirs = ($maildir . $key . "cur/" , $maildir . $key . "new/" );
    foreach $dir (@maildirs) {
 if ($debug) {print "In $dir\n";}
 opendir(DIR, $dir) or die "Can't open $dir: $!";
 while( defined ($file = readdir DIR) ) {
     $fullname = $dir . $file;
     $_ = $file ;
     if (/:2,(.*)$/) {
  $sb = stat($fullname);
  $inode = $sb->ino;
                $tags = $1;
                $mdate = $sb->mtime;
  $nlinks = $sb->nlink;
  $emailtags{$inode} = $tags;
  unless (($opt_p) && ($nlinks > 1)) {
      $_= $tags;
      if (/T/) { # Message is flagged as deleted - move to trash
   $trashemails{$inode} = $fullname;
   $trashemaildates{$inode} = $dates;
      } else {
   $emails{$inode} = $fullname;
   $emaildates{$inode} = $mdate;
      }
  }
     }
 }    
 closedir(DIR);
    }
    $mhcount = $mhsize{$key} + 1;
    if ($debug) {print "In $key: starting at $mhcount\n";}
    foreach $inode (sort { $emaildates{$a} <=> $emaildates{$b} } (keys(%emaildates)) ) {  # This will go through the emails in mtime order
 link $emails{$inode}, $cwd . $mhcount;
 $mhcount++;
    }
    unless (($opt_q) || ($opt_p)) {
 print "Sorting $folderslist{$key}\n";
 $cmdout = `sortm +$folderslist{$key}`;
    }
    $markfile = $cwd . ".sylpheed_mark";
    if ($debug) {print "Creating $markfile\n";}
    open (MARK, ">$markfile") || die "Cannot create mark file\n";
    binmode MARK;
    $version_int = 2;
    $version = pack('I',$version_int);
    print MARK $version;
    $mhcount = 1;
    while ( -f $cwd . $mhcount) {
        $mesg = pack('I',$mhcount);
 print MARK $mesg;
 $fullname = $cwd . $mhcount;
 $sb = stat($fullname);
 $inode = $sb->ino;
        $tag_int = 1;
 $_ = $emailtags{$inode};
 if (/S/) {
     $tag_int = 0;
 } else {
     $tag_int += 2;
 }
 if (/R/) {$tag_int += 16;}
 if (/F/) {$tag_int += 4;}
 $tag = pack('I',$tag_int);
 print MARK $tag;
 $mhcount++;
    }
    close MARK;
}
# % Now deal with the deleted email
    # Now accumulate all the emails in the Maildir
my ($key, $folder) = %trashfolder ;
$cwd = $trashdir;
@maildirs = ($maildir . $key . "cur/" , $maildir . $key . "new/" );
foreach $dir (@maildirs) {
    if ($debug) {print "In $dir\n";}
    opendir(DIR, $dir) or die "Can't open $dir: $!";
    while( defined ($file = readdir DIR) ) {
 $fullname = $dir . $file;
 $_ = $file ;
 if (/:2,(.*)$/) {
     $sb = stat($fullname);
     $inode = $sb->ino;
     $tags = $1;
            $mdate = $sb->mtime;
            $nlinks = $sb->nlink;
     $emailtags{$inode} = $tags;
     unless (($opt_p) && ($nlinks > 1)) {
  $trashemails{$inode} = $fullname;
  $trashemaildates{$inode} = $mtime;
     }
 }
    }    
    closedir(DIR);
}
$trashcount = $trashsize + 1;
if ($debug) {print "In trash: starting at $trashcount\n";}
foreach $inode (sort { $trashemaildates{$a} <=> $trashemaildates{$b} } (keys(%trashemaildates)) ) {  # This will go through the emails in mtime order
    link $trashemails{$inode}, $cwd . $trashcount;
    $trashcount++;
}
unless (($opt_q) || ($opt_p)) {
    print "Sorting $folder\n";
    $cmdout = `sortm +$folder`;
}
$markfile = $cwd . ".sylpheed_mark";
if ($debug) {print "Creating $markfile\n";}
open (MARK, ">$markfile") || die "Cannot create mark file\n";
binmode MARK;
$version_int = 2;
$version = pack('I',$version_int);
print MARK $version;
$mhcount = 1;
while ( -f $cwd . $mhcount) {
    $mesg = pack('I',$mhcount);
    print MARK $mesg;
    $fullname = $cwd . $mhcount;
    $sb = stat($fullname);
    $inode = $sb->ino;
    $tag_int = 1;
    $_ = $emailtags{$inode};
    if (/S/) {
 $tag_int = 0;
    } else {
 $tag_int += 2;
    }
    if (/R/) {$tag_int += 16;}
    if (/F/) {$tag_int += 4;}
    $tag = pack('I',$tag_int);
    print MARK $tag;
    $mhcount++;
}
close MARK;


