package Map::Tube::GraphViz;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use GraphViz2;
use List::MoreUtils qw(none);
use Map::Tube::GraphViz::Utils qw(node_color);
use Readonly;
use Scalar::Util qw(blessed);

# Constants.
Readonly::Array our @OUTPUTS => qw(text png);

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Edge callback.
	$self->{'callback_edge'} = sub {
		my ($self, $from, $to) = @_;
		$self->{'_g'}->add_edge(
			'from' => $from,
			'to' => $to,
		);
		return;
	};

	# Node callback.
	$self->{'callback_node'} = \&node_color;

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
	if (! defined $self->{'output'}) {
		err "Parameter 'output' is required.";
	}
	if (none { $self->{'output'} eq $_ } @OUTPUTS) {
		err "Unsupported 'output' parameter '$self->{'output'}'.";
	}

	# GraphViz object.
	my $name = $self->{'tube'}->name;
	$self->{'_g'} = GraphViz2->new(
		'global' => {
			'directed' => 0,
		},
		$name ? (
			'graph' => {
				'label' => $name,
				'labelloc' => 'top',
			},
		) : (),
	);

	# Object.
	return $self;
}

# Get graph.
sub graph {
	my ($self, $output_file) = @_;
	foreach my $node (values %{$self->{'tube'}->nodes}) {
		$self->{'callback_node'}->($self, $node);
	}
	my @processed;
	foreach my $node (values %{$self->{'tube'}->nodes}) {
		foreach my $link (split m/,/ms, $node->link) {
			if (none {
				($_->[0] eq $node->id && $_->[1] eq $link) 
				|| 
				($_->[0] eq $link && $_->[1] eq $node->id)
				} @processed) {

				$self->{'callback_edge'}->($node->id, $link);
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
