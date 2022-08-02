#!/usr/bin/perl -w
use strict;

while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($line =~ /^([0-9]+) /){
	print int(($1+0.0)/4.0) . "\n";
    }
}

