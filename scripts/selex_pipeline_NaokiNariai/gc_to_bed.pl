#!/usr/bin/perl -w
use strict;

#<STDIN>;

my $index = 0;
my $gc_val = 0;
my $chr = "";
my $pos = 0;

while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($line =~ /variableStep\schrom=(chr.+)\s/){
	$chr = $1;
	$index = 0;
	$gc_val = 0;
	$pos = 0;
    }
    else{
	my @tmp = split(/\t/, $line);

	if($index == 0){
	    $pos = $tmp[0];
	    $gc_val = $tmp[1];
	    $index++;
	}
	elsif($index % 10 == 0){
	    print $chr . "\t" . $pos . "\t" . ($pos + 5 * 10) . "\t" . ($gc_val / 10.0) . "\n";
	    $pos = $tmp[0];
	    $gc_val = $tmp[1];
	    $index++;
	}
	else{
	    $gc_val += $tmp[1];
	    $index++;
	}
    }
}

