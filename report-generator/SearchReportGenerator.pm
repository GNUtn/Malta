package SearchReportGenerator;
use Moose;
use URI::QueryParam;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(query)]});
has '+sort_field' => (default => 'ocurrencias');
has '+file_name' => (default => 'searchs.json');

sub parse_values {

	#Por ahora, sólo busca para google, yahoo, bing y algún otro que
	#tenga /search?q= en la url
	my ( $self, $values ) = @_;

	my $url = @$values[ $self->config->{fields}->{'cs-uri'} ];
	my $uri = $self->parse_url($url);

	if ( $uri->path =~ m/search/ ) {
		my $query;
		if ( $uri->query_param('oq') ) {
			$query = $uri->query_param('oq');
		}
		elsif ( $uri->query_param('q') ) {
			$query = $uri->query_param('q');
		}
		elsif ( $uri->query_param('p') ) {
			$query = $uri->query_param('p');
		}
		if ( $query && length($query) > $self->config->search_length ) {
			my $date = @$values[ $self->config->{fields}->{'date'} ];
			my $entry = $self->get_entry( $date, lc $query );
			$entry->{ocurrencias} += 1;
		}
	}
}
__PACKAGE__->meta->make_immutable;
1;
