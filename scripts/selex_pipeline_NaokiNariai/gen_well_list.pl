#!/usr/bin/perl -w
use strict;

#my @oligo = (1, 2, 3, 4);
my @oligo = (1, 2);
my @well_r = ("A", "B", "C", "D", "E", "F", "G", "H");
my @well_c = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);

for(my $i=0;$i<$#oligo+1;$i++){
    for(my $j=0;$j<$#well_r+1;$j++){
	for(my $k=0;$k<$#well_c+1;$k++){
	    print $oligo[$i] . "_" . $well_r[$j] . "" . $well_c[$k] . "\n";
	}
    }
}

