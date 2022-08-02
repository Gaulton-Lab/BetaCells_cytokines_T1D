#!/usr/bin/perl -w
use strict;

my $threshold = $ARGV[0];

my $current_snp = "";
my $current_REF_num = 0;
my $current_ALT_num = 0;

my $index = 0;

while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($line =~ /([0-9]+) (.+?_[ATGC]+_[ATGC]+)_(...)_[ATGC]/){
		my $num = $1;
		my $snp = $2;
		my $nuc = $3;
		if($index == 0){
		    $current_snp = $snp;
		}
		elsif($snp eq $current_snp){
		}
		else{
		    if(($current_REF_num + $current_ALT_num) >=4){
				print $current_snp . "\t" . $current_REF_num . "\t" . $current_ALT_num . "\n";
		    }
		    $current_snp = $snp;
		    $current_REF_num = 0;
		    $current_ALT_num = 0;
		}
	
		if($nuc eq "REF"){
		    $current_REF_num += $num;
		}
		elsif($nuc eq "ALT"){
		    $current_ALT_num += $num;
		}
    }

    $index++;
}

if(($current_REF_num + $current_ALT_num) >= 4){
    print $current_snp . "\t" . $current_REF_num . "\t" . $current_ALT_num . "\n";
}
