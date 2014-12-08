# Pragmas.
use strict;
use warnings;

# Modules.
use inc::Module::Install;

# Definition.
abstract 'GraphViz interface to the Tube Map.';
author 'Michal Spacek <skim@cpan.org>';
license 'bsd';
license 'artistic_2';
name 'Map-Tube-GraphViz';
readme_from 'GraphViz.pm';
requires 'Map::Tube' => '2.41';
requires 'Moo' => 0;
requires 'namespace::clean' => 0;
requires 'perl' => '5.8.0';
resources 'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html'.
	'?Name=Map-Tube-GraphViz';
resources 'homepage' => 'https://github.com/tupinek/Map-Tube-GraphViz';
resources 'repository' => 'git://github.com/tupinek/Map-Tube-GraphViz';
test_requires 'English' => 0;
test_requires 'File::Object' => 0.08;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
test_requires 'Test::Pod' => 0;
test_requires 'Test::Pod::Coverage' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
