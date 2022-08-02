#!/usr/bin/perl -w
use strict;

while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($line =~ /^\s*([0-9]+)\s+(.+)$/){
	print $2 . "\t" . $1 . "\n";
    }
}

