use strict;
use warnings;

use Map::Tube::GraphViz;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Map::Tube::GraphViz::VERSION, 0.08, 'Version.');
