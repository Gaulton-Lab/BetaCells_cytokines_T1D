#!/usr/bin/perl -w
use strict;

while(<STDIN>){
    my $line = $_;
    chomp($line);
    my @tmp = split(/\t/, $line);

    if($#tmp+1>=11 && $tmp[2] ne "*"){
	print $tmp[2] . "\n";
    }
}

