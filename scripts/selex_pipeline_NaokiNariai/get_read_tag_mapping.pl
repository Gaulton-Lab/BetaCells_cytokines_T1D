#!/usr/bin/perl -w
use strict;

while(<STDIN>){
    my $line = $_;
    chomp($line);
    my @tmp = split(/\t/, $line);

    if($#tmp+1>=11 && $tmp[4] == 60){
	if($tmp[5] eq "44M"){

	    my $str = $tmp[9];
	    my $allele = substr($str, 21, 1);

	    my $tag1 = substr($str, 0, 2);
	    my $tag2 = substr($str, 42, 2);
	    print $tmp[2] . "_" . $allele . "_" . $tag1 . $tag2 . "\n";

#	    #print $tmp[5] . "\n";
	}
	elsif($tmp[5] eq "2S42M"){

	    my $str = $tmp[9];
	    my $allele = substr($str, 21, 1);

	    my $tag1 = substr($str, 0, 2);
	    my $tag2 = substr($str, 42, 2);
	    print $tmp[2] . "_" . $allele . "_" . $tag1 . $tag2 . "\n";


#	    print $tmp[5] . "\n";
	}
	elsif($tmp[5] eq "42M2S"){

	    my $str = $tmp[9];
	    my $allele = substr($str, 21, 1);

	    my $tag1 = substr($str, 0, 2);
	    my $tag2 = substr($str, 42, 2);
	    print $tmp[2] . "_" . $allele . "_" . $tag1 . $tag2 . "\n";


#	    print $tmp[5] . "\n";
    	}
	elsif($tmp[5] eq "2S40M2S"){

	    my $str = $tmp[9];
	    my $allele = substr($str, 21, 1);

	    my $tag1 = substr($str, 0, 2);
	    my $tag2 = substr($str, 42, 2);
	    print $tmp[2] . "_" . $allele . "_" . $tag1 . $tag2 . "\n";


#	    print $tmp[5] . "\n";
    	}
    }
}

