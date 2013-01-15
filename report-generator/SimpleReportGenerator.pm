package SimpleReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(categoria)]});
has '+sort_field' => (default => 'ocurrencias');

# El nombre del campo sobre el que se realiza la cuenta.
has 'field' =>(
	is      => 'rw',
	isa     => 'Str'
);

# Nombre de campo sobre el que se quiere filtrar.
has 'filter_field' =>(
	is      => 'rw',
	isa     => 'Str'
);

# Condición regex a aplicar para filtrar.
has 'filter_condition' =>(
	is      => 'rw',
	isa     => 'Str'
);

sub parse_values {
	my ( $self, $values ) = @_;
	
	#TODO: agregar filtro (usar filter_field y filter_condition)
	my $category = @$values[ $self->config->{fields}->{$self->field} ];
	my $date     = @$values[ $self->config->{fields}->{'date'} ];
	my $entry    = $self->get_entry( $date, $category );
	$entry->{ocurrencias} += 1;
}
__PACKAGE__->meta->make_immutable;
1;