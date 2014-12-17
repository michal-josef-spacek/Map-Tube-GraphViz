#!/usr/bin/env perl

# Pragmas.
use strict;
use warnings;

# Modules.
use English;
use Error::Pure qw(err);
use Map::Tube::GraphViz;

# Arguments.
if (@ARGV < 1) {
        print STDERR "Usage: $0 metro\n";
        exit 1;
}
my $metro = $ARGV[0];

# Object.
my $class = 'Map::Tube::'.$metro;
eval "require $class;";
if ($EVAL_ERROR) {
        err "Cannot load '$class' class.",
                'Error', $EVAL_ERROR;
}

# Metro object.
my $tube = eval "$class->new";
if ($EVAL_ERROR) {
        err "Cannot create object for '$class' class.",
                'Error', $EVAL_ERROR;
}

# GraphViz object.
my $g = Map::Tube::GraphViz->new(
        'driver' => 'neato',
        'tube' => $tube,
);

# Get graph to file.
$g->graph($metro.'.png');

# Print file.
system "ls -l $metro.png";

# Output without arguments like:
# Usage: /tmp/SZXfa2g154 metro

# Output with 'Berlin' argument like:
# -rw-r--r-- 1 skim skim 1503518 Dec 17 01:10 Berlin.png