package PaginasReportGenerator;
use Mouse;
use URI;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $url = @$values[ $self->config->{fields}->{'cs-uri'} ];
	if ($url !~ /.*\/\/.*/) {
		$url = "http://".$url;
	}
	my $uri = URI->new( $url );
	my $entry = $self->get_entry( $uri->host, $uri->path );
	$entry->{ocurrencias} += 1;
}

sub update_totals {
	my ($self) = @_;

	foreach my $destino ( keys %{ $self->data_hash } ) {
		foreach my $pagina ( keys %{ $self->data_hash->{$destino} } ) {
			$self->data_hash->{$destino}->{$pagina}->{porcentaje} = Utils->porcentaje(
				$self->data_hash->{$destino}->{$pagina}->{ocurrencias},
				$self->global_stats->{peticiones} );
		}
	}
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
	my %entry = (
		ocurrencias => 0,
		porcentaje  => 0
	);
	return \%entry;
}
1;
