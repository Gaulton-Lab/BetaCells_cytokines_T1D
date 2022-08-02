#!/usr/bin/perl -w
use strict;

my %len_cnt = ();

my $index = 0;
while(<STDIN>){
    my $line = $_;
    chomp($line);

    my $len = 0;
    if($index == 1){
	$len = length($line);
#	print $len . "\n";
	if(exists($len_cnt{$len})){
	    $len_cnt{$len}++;
	}
	else{
	    $len_cnt{$len} = 1;
	}
    }

    $index++;
    if($index == 4){
	$index = 0;
    }
}

foreach my $key (keys %len_cnt){
    print $key . "\t" . $len_cnt{$key} . "\n";
}
