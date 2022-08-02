#!/usr/bin/perl -w
use strict;

my $WELL_LIST = $ARGV[0];
my $CYCLE = $ARGV[1];

print "#!/bin/bash\n";
#print "export PATH=/frazer01/home/nnariai/anaconda2/bin:\$PATH\n";

print "SEEDFILE=${WELL_LIST}\n";
print "WELL=\$(awk \"NR==\$SGE_TASK_ID\" \$SEEDFILE)\n";

print "module add gcc\n";
#print "module load cardips\n";
#print "source activate dhs\n";
print "make -i WELL=\$\{WELL\} CYCLE=${CYCLE} run_pipeline\n";
