#!/usr/bin/perl -w
use strict;

my $threshold = $ARGV[0];

my $current_snp = "";
my $current_A_num = 0;
my $current_T_num = 0;
my $current_G_num = 0;
my $current_C_num = 0;

my $index = 0;

while(<STDIN>){
    my $line = $_;
    chomp($line);

    if($line =~ /([0-9]+) (.+)_N_([ATGC])/){
	my $num = $1;
	my $snp = $2;
	my $nuc = $3;
	if($index == 0){
	    $current_snp = $snp;
	}
	elsif($snp eq $current_snp){
	}
	else{
	    if(($current_A_num + $current_T_num + $current_G_num + $current_C_num) >=8){
		print $current_snp . "\t" . $current_A_num . "\t" . $current_T_num . "\t" . $current_G_num . "\t" . $current_C_num . "\n";
	    }
	    $current_snp = $snp;
	    $current_A_num = 0;
	    $current_T_num = 0;
	    $current_G_num = 0;
	    $current_C_num = 0;
	}

	if($nuc eq "A"){
	    $current_A_num += $num;
	}
	elsif($nuc eq "T"){
	    $current_T_num += $num;
	}
	elsif($nuc eq "G"){
	    $current_G_num += $num;
	}
	elsif($nuc eq "C"){
	    $current_C_num += $num;
	}
    }

    $index++;
}

if(($current_A_num + $current_T_num + $current_G_num + $current_C_num) >=8 ){
    print $current_snp . "\t" . $current_A_num . "\t" . $current_T_num . "\t" . $current_G_num . "\t" . $current_C_num . "\n";
}
