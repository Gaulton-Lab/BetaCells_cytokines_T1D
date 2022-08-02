#!/usr/bin/perl -w
use strict;

my $count = 0;
while(<STDIN>){
    my $line = $_;
    chomp($line);
    my @tmp = split(/\t/, $line);
    if($tmp[1] >= 5 &&
       $tmp[2] >= 5 &&
       $tmp[3] >= 5 &&
       $tmp[4] >= 5){
	$count++;
    }
}
print $count . "\n";
