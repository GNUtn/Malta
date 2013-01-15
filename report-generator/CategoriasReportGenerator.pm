package CategoriasReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(categoria)]});
has '+sort_field' => (default => 'ocurrencias');
has '+file_name' => (default => 'categorias.json');

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];

	if ( $action eq 'Denied' ) {
		my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
		my $date     = @$values[ $self->config->{fields}->{'date'} ];
		my $entry    = $self->get_entry( $date, $category );
		$entry->{ocurrencias} += 1;
	}
}
__PACKAGE__->meta->make_immutable;
1;
