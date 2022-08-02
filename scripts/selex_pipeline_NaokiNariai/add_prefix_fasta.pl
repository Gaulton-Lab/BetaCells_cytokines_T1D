#!/usr/bin/perl -w
use strict;

my $prefix = $ARGV[0];
my $index = 0;

while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($index % 2 == 0){
	if($line =~ /\>(.+)/){
	    print ">" . $prefix . $1 . "\n";
	}
    }
    else{
	print $line . "\n";
    }

    $index++;
}

