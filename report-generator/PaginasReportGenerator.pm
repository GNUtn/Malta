package PaginasReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(destino)]});
has '+sort_field' => (default => 'trafico');
has '+file_name' => (default => 'paginas.json');

sub parse_values {
	my ( $self, $values ) = @_;
	my $uri = $self->parse_url( $self->get_url($values) );
	eval { $uri->host };
	if ( !$@ ) {
		my $date = @$values[ $self->config->{fields}->{'date'} ];
		my $entry = $self->get_entry( $date, $uri->host );
		$entry->{ocurrencias} += 1;
		$entry->{trafico} += $self->get_trafico($values);
	}
}

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, trafico => 0 );
	return \%entry;
};
__PACKAGE__->meta->make_immutable;
1;
