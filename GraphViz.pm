package Map::Tube::GraphViz;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use GraphViz2;
use List::MoreUtils qw(none);
use Readonly;
use Scalar::Util qw(blessed);

# Constants.
Readonly::Array our @COLORS => qw(red green yellow cyan magenta blue grey
	orange brown white greenyellow red4 violet tomato cadetblue aquamarine
	lawngreen indigo deeppink darkslategrey khaki thistle peru darkgreen
);
Readonly::Array our @OUTPUTS => qw(text png);

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Color callback.
	$self->{'color_callback'} = sub {
		my $line = shift;
		if (! exists $self->{'_color_line'}->{$line}) {
			if (! exists $self->{'_color_index'}) {
				$self->{'_color_index'} = 0;
			} else {
				$self->{'_color_index'}++;
				if ($self->{'_color_index'} > $#COLORS) {
					err "No color for line '$line'.";
				}
			}
			my $rand_color = $COLORS[$self->{'_color_index'}];
			$self->{'_color_line'}->{$line} = $rand_color;
		}
		return $self->{'_color_line'}->{$line};
	};

	# Driver.
	$self->{'driver'} = 'dot';

	# Output.
	$self->{'output'} = 'png';

	# Map::Tube object.
	$self->{'tube'} = undef;

	# Process params.
	set_params($self, @params);

	# Check Map::Tube object.
	if (! defined $self->{'tube'}) {
		err "Parameter 'tube' is required.";
	}
	if (! blessed($self->{'tube'})
		|| ! $self->{'tube'}->does('Map::Tube')) {

		err "Parameter 'tube' must be 'Map::Tube' object.";
	}

	# Check output.
	# TODO

	# GraphViz object.
	$self->{'_g'} = GraphViz2->new(
		'global' => {
			'directed' => 0,
		},
	);

	# Object.
	return $self;
}

# Get graph.
sub graph {
	my ($self, $output_file) = @_;
	foreach my $node (values %{$self->{'tube'}->nodes}) {
		my $node_links = split m/,/ms, $node->link;
		my %params;
		if ($node_links > 2) {
			%params = (
				'fillcolor' => 'yellow',
				'style' => 'filled',
				'shape' => 'diamond',
			);
		} elsif ($node_links == 1) {
			%params = (
				'fillcolor' => 'cyan',
				'style' => 'filled',
				'shape' => 'box',
			);
		}
		$self->{'_g'}->add_node(
			'label' => $node->name,
			'name' => $node->id,
			%params,
		);
	}
	my @processed;
	foreach my $node (values %{$self->{'tube'}->nodes}) {
		foreach my $link (split m/,/ms, $node->link) {
			if (none {
				($_->[0] eq $node->id && $_->[1] eq $link) 
				|| 
				($_->[0] eq $link && $_->[1] eq $node->id)
				} @processed) {

				$self->{'_g'}->add_edge(
					'from' => $node->id,
					'to' => $link,
				);
				push @processed, [$node->id, $link];
			}
		}
	}
	return $self->{'_g'}->run(
		'driver' => $self->{'driver'},
		'format' => $self->{'output'},
		'output_file' => $output_file,
	);
}

1;

__END__
