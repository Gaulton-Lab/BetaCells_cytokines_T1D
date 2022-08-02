#!/usr/bin/perl

use strict;

my $verbose = 0;
while($_ = shift @ARGV) {
	if(/^-v/) {
		$verbose = 1;
	}
}

my($total, $nqual, $nunpair, $nallele, $nmatch) = (0,0,0,0,0,0);
while(<STDIN>) {
	/^@/ && next;
	chomp;
	my $r1 = $_;
	$_ = <STDIN>;
	chomp;
	my $r2 = $_;

	$total ++;
	my($id1, $name1, $pos1, $q1, $cigar1, $seq1) = (split /\t/, $r1)[0,2,3,4,5,9];
	my($id2, $name2, $pos2, $q2, $cigar2, $seq2) = (split /\t/, $r2)[0,2,3,4,5,9];
	$id1 eq $id2 || die "The input reads are not in the order ($id1,$id2)";
	if(($q1 != 60) or ($q2 != 60)) {
		$nqual ++; next;
	}
	if($name1 ne $name2) {
		$nunpair ++; next;
	}
	my $p = 47 - $pos1;
	if($cigar1 =~ /^(\d+)S/) {
		$p += $1;
	}
	my $a1 = (split //, $seq1)[$p];
	my $p = 47 - $pos2;
	if($cigar2 =~ /^(\d+)S/) {
		$p += $1;
	}
	my $a2 = (split //, $seq2)[$p];
	if($a1 ne $a2) {
		$nallele ++; next;
	}
	$nmatch ++;
	print join("_", $name1, $a1), "\n";
}

if($verbose) {
	print STDERR "# of total pairs: $total\n";
	print STDERR "# of pairs with low quality: $nqual\n";
	print STDERR "# of pairs mapped on different reference: $nunpair\n";
	print STDERR "# of paris having different alleles: $nallele\n";
	print STDERR "# of pairs correctly counted: $nmatch\n";
}

exit;
