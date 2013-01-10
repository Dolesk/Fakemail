#!/usr/bin/perl

use Term::ANSIColor;
use Term::ReadKey;

$uid = `whoami`;
chop $uid;

if ($uid eq 'root') {
 system("clear");
 START:

 print color("red"), "\n   _____        __                         .__.__   ";
 print "\n _/ ____\\\____  |  | __ ____   _____ _____  |__|  |  ";
 print "\n \\\   __\\\\__  \\\ |  |/ // __ \\\ /     \\\\__  \\\ |  |  |  ";
 print "\n  |  |   / __ \\\|    <\\\  ___/|  Y Y  \\\/ __ \\\|  |  |__";
 print "\n  |__|  (____  /__|_ \\\\___  >__|_|  (____  /__|____/";
 print "\n             \\\/     \\\/    \\\/      \\\/     \\\/    v0.2", color("reset");

 print "\n\nsendmail pid: ";
 $pid = system("pidof -s sendmail-mta");
 if ( $pid != 0 ) {
  print "\n\nsendmail is not running!\n";
  #system("service sendmail start");
  system("systemctl start sendmail");
  print "done!\n";
 }

 print "\nPlease enter sender's name: ";
 $name = <STDIN>;
 chop $name;
 TRYFROM:
 print "Please enter sender's e-mail address: ";
 $from = <STDIN>;
 chop $from;
 if ($from =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/) {
  print "$from is valid!\n";
 } else {
  print "$from is invalid. Try again!\n";
  goto TRYFROM;
 }
 TRYTO:
 print "Please enter receiver's e-mail address: ";
 $to = <STDIN>;
 chop $to;
 if ($to =~ /^(\w|\-|\_|\.)+\@((\w|\-|\_)+\.)+[a-zA-Z]{2,}$/) {
  print "$to is valid!\n";
 } else {
  print "$to is invalid. Try again!\n";
  goto TRYTO;
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

 open(MAIL, "|/usr/sbin/sendmail -t");
 print MAIL "To: $to\n";
 print MAIL "From: $name <$from>\n";
 print MAIL "Subject: $subject\n\n";
 print MAIL "$message";
 close(MAIL);

 system("rm message.txt");
 print "\nMessage sent to $to!\n";
} else {
 print "$uid, you have to be root to execute the program!\n";
}
