#!/usr/bin/perl -w
use strict;

while(<STDIN>){
    my $line = $_;
    chomp($line);
    my @tmp = split(/\t/, $line);
    
    my $chr = "";
    my $pos_1 = 0;
    my $pos_2 = 0;
    if($tmp[0] =~ /(.+)_(.+)_(\d+)/){
	$chr = 'chr' . $2;
	$pos_1 = ($3 - 1);
	$pos_2 = $3;
    }

    print $chr . "\t" . $pos_1 . "\t" . $pos_2 . "\n";
}
