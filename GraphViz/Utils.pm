package Map::Tube::GraphViz::Utils;

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Error::Pure qw(err);
use Readonly;

# Constants.
Readonly::Array our @EXPORT_OK => qw(node_color node_color_without_label
	color_line);
Readonly::Array our @COLORS => qw(red green yellow cyan magenta blue grey
	orange brown white greenyellow red4 violet tomato cadetblue aquamarine
	lawngreen indigo deeppink darkslategrey khaki thistle peru darkgreen
);

# Version.
our $VERSION = 0.01;

# Create GraphViz color node.
sub node_color {
	my ($obj, $node) = @_;
	my @node_lines = split m/,/ms, $node->line;
	my %params;
	if (@node_lines == 1) {
		%params = (
			'style' => 'filled',
			'fillcolor' => color_line($obj, $node_lines[0]),
		);
	} else {
		%params = (
			'style' => 'wedged',
			'fillcolor' => (join ':', map {
				color_line($obj, $_);
			} @node_lines),
		);
	}
	$obj->{'_g'}->add_node(
		'label' => $node->name,
		'name' => $node->id,
		%params,
	);
	return;
}

# Create GraphViz color node without label.
sub node_color_without_label {
	my ($obj, $node) = @_;
	my @node_lines = split m/,/ms, $node->line;
	my %params;
	if (@node_lines == 1) {
		%params = (
			'style' => 'filled',
			'fillcolor' => color_line($obj, $node_lines[0]),
		);
	} else {
		%params = (
			'style' => 'wedged',
			'fillcolor' => (join ':', map {
				color_line($obj, $_);
			} @node_lines),
		);
	}
	$obj->{'_g'}->add_node(
		'label' => '',
		'name' => $node->id,
		%params,
	);
	return;
}

# Get line color.
sub color_line {
	my ($obj, $line) = @_;
	if (! exists $obj->{'_color_line'}->{$line}) {
		if (! exists $obj->{'_color_index'}) {
			$obj->{'_color_index'} = 0;
		} else {
			$obj->{'_color_index'}++;
			if ($obj->{'_color_index'} > $#COLORS) {
				err "No color for line '$line'.";
			}
		}
		my $rand_color = $COLORS[$obj->{'_color_index'}];
		$obj->{'_color_line'}->{$line} = $rand_color;
	}
	return $obj->{'_color_line'}->{$line};
}

1;

__END__
