package PaginasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $url   = @$values[ $self->config->{fields}->{'cs-uri'} ];
	my $uri   = $self->parse_url($url);
	my $entry = $self->get_entry( $uri->host, $uri->path );
	$entry->{ocurrencias} += 1;
}

sub get_file_name {
	return "paginas.json";
}

sub get_entry {
	my ( $self, $destino, $pagina ) = @_;

	if ( !exists $self->data_hash->{$destino}->{$pagina} ) {
		$self->data_hash->{$destino}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$destino}->{$pagina};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(destino pagina)];
}
1;
