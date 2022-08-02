#!/usr/bin/perl -w
use strict;

my $num = 0;
while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($line =~ /([0-9]+) (T.+)$/){
#	print $2 . "\t" . $1 . "\n";
	if($1 >= 5){
	    $num = $num+1;
	}
    }
}
print $num . "\n";

