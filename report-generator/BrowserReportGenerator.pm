package BrowserReportGenerator;
use Moose;
use HTML::ParseBrowser;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(categoria)]});
has '+sort_field' => (default => 'ocurrencias');
has '+file_name' => (default => 'browsers.json');

# El nombre del campo sobre el que se realiza la cuenta.
has 'field' => (
	is  => 'rw',
	isa => 'Str'
);

sub parse_values {
	my ( $self, $values ) = @_;

	#TODO: agregar filtro (usar filter_field y filter_condition)
	my $category = @$values[ $self->config->{fields}->{ $self->field } ];
	my $ua       = HTML::ParseBrowser->new($category);
	if ( $ua->name ) {
		my $data  = $ua->name;
		my $date  = @$values[ $self->config->{fields}->{'date'} ];
		my $entry = $self->get_entry( $date, $data );
		$entry->{ocurrencias} += 1;
	}
}
__PACKAGE__->meta->make_immutable;
1;
