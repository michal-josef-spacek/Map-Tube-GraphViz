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
our $VERSION = 0.02;

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

				$self->{'callback_edge'}->($self, $node->id,
					$link);
				push @processed, [$node->id, $link];
			}
		}
	}
	$self->{'_g'}->run(
		'driver' => $self->{'driver'},
		'format' => $self->{'output'},
		'output_file' => $output_file,
	);
	return;
}

1;

__END__

=encoding utf8

=head1 NAME

Map::Tube::GraphViz - GraphViz output for Map::Tube.

=head1 SYNOPSIS

 use Map::Tube::GraphViz;
 my $obj = Map::Tube::GraphViz->new(%params);
 $obj->graph($output_file);

=head1 METHODS

=over 8

=item C<new(%params)>

 Constructor.

=over 8

=item * C<callback_edge>

 Edge callback.
 Default value is this:
 sub { 
         my ($self, $from, $to) = @_;
         $self->{'_g'}->add_edge(
         	'from' => $from,
         	'to' => $to,
         );
         return;
 }

=item * C<callback_node>

 Node callback.
 Default value is \&Map::Tube::GraphViz::Utils::node_color.

=item * C<driver>

 GraphViz2 driver.
 Default value is 'dot'.

=item * C<output>

 GraphViz2 output.
 It is required.
 Default value is 'png'.
 Possible values are 'png' and 'text'.

=item * C<tube>

 Map::Tube object.
 It is required.
 Default value is undef.

=back

=item C<graph($output_file)>
 
 Get graph and save it to $output_file file.
 Returns undef.

=back

=head1 ERRORS

 new():
         Parameter 'tube' is required.
         Parameter 'tube' must be 'Map::Tube' object.
         Parameter 'output' is required.
         Unsupported 'output' parameter '%s'.
         From Map::Tube::GraphViz::Utils::color_line():
                 No color for line '%s'.
         From Class::Utils::set_params():
                 Unknown parameter '%s'.

=head1 EXAMPLE1

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

=head1 EXAMPLE2

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use English;
 use Error::Pure qw(err);
 use Map::Tube::GraphViz;
 use Map::Tube::GraphViz::Utils qw(node_color_without_label);

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
         'callback_node' => \&node_color_without_label,
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

=head1 DEPENDENCIES

L<Class::Utils>,
L<Error::Pure>,
L<GraphViz2>,
L<List::MoreUtils>,
L<Map::Tube::GraphViz::Utils>,
L<Readonly>,
L<Scalar::Util>.

=head1 SEE ALSO

L<Map::Tube>.

=head1 REPOSITORY

L<https://github.com/tupinek/Map-Tube-GraphViz>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

 © 2014 Michal Špaček
 Artistic License
 BSD 2-Clause License

=head1 VERSION

0.02

=cut
