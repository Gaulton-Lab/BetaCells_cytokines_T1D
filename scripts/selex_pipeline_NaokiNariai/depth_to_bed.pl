#!/usr/bin/perl -w
use strict;

while(<STDIN>){
    my $line = $_;
    chomp($line);
    my @tmp = split(/\t/, $line);

    print $tmp[0] . "\t" . ($tmp[1]-1) . "\t" . $tmp[1] . "\t" . $tmp[2] . "\n";
}


