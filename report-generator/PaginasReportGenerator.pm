package PaginasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $uri   = $self->parse_url($self->get_url($values));
	my $entry = $self->get_entry( $uri->host );
	$entry->{ocurrencias} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "paginas.json";
}

sub get_entry {
	my ( $self, $destino ) = @_;

	if ( !exists $self->data_hash->{$destino} ) {
		$self->data_hash->{$destino} = $self->new_entry;
	}

	return $self->data_hash->{$destino};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, trafico => 0 );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(destino)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'trafico';
}
1;
