#!/usr/bin/perl

use Term::ANSIColor;
use Term::ReadKey;
use Mail::Sendmail;

$correctfrom = 0;
$correctto = 0;

$uid = `whoami`;
chop $uid;

if ($uid eq 'root') {
 system("clear");

 print color("red"), "\n   _____        __                         .__.__   ";
 print "\n _/ ____\\\____  |  | __ ____   _____ _____  |__|  |  ";
 print "\n \\\   __\\\\__  \\\ |  |/ // __ \\\ /     \\\\__  \\\ |  |  |  ";
 print "\n  |  |   / __ \\\|    <\\\  ___/|  Y Y  \\\/ __ \\\|  |  |__";
 print "\n  |__|  (____  /__|_ \\\\___  >__|_|  (____  /__|____/";
 print "\n             \\\/     \\\/    \\\/      \\\/     \\\/    v0.2", color("reset");

 system("systemctl start saslauthd.service");
 system("systemctl start sendmail.service");
 system("systemctl start sm-client.service");
 print "Initiated required services.\n";

 print "\nPlease enter sender's name: ";
 $name = <STDIN>;
 chop $name;
 while (!$correctfrom){
  print "Please enter sender's e-mail address: ";
  $from = <STDIN>;
  chop $from;
  if ($from =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/) {
   print "$from is valid!\n";
   $correctfrom = 1;
  } else {
   print "$from is invalid. Try again!\n";
  }
 }

 while (!$correctto){
  print "Please enter receiver's e-mail address: ";
  $to = <STDIN>;
  chop $to;
  if ($to =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/) {
   print "$to is valid!\n";
   $correctto = 1;
  } else {
   print "$to is invalid. Try again!\n";
  }
 }
 
 print "Select subject: ";
 $subject = <STDIN>;
 chop $subject;
 print "\nPlease press any key to start composing the message.\nThen when ready press ctrl+x and save it by pressing 'y'.\n";
 ReadMode 4;
 while (not defined ($dumb = ReadKey(-1))) {
 }
 ReadMode 0;
 system("nano message.txt");
 local $/=undef;
 open(MESSAGE, "message.txt") || die("Could not open file!");
 binmode MESSAGE;
 $message = <MESSAGE>;
 close(MESSAGE) || die("Could not close file!");

 %mail = ( To    	=> "$to",
           From  	=> "$name <$from>",
           Subject	=> "$subject",
           Message	=> "$message"
         );

 sendmail(%mail) or die $Mail::Sendmail::error;

 print "OK. Log says:\n", $Mail::Sendmail::log;
 print "\n";

 system("rm message.txt");
 print "\nMessage sent to $to!\n";
} else {
 print "$uid, you have to be root to execute the program!\n";
}
