package ReferredReportGenerator;
use Mouse;
extends 'PaginasReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $url   = @$values[ $self->config->{fields}->{'cs-referred'} ];
	my $uri   = $self->parse_url($url);
	my $entry = $self->get_entry( $uri->host, $uri->path );
	$entry->{ocurrencias} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "referred.json";
}
1;
