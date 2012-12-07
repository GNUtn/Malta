package PaginasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $uri   = $self->parse_url($self->get_url($values));
	eval {$uri->host};
	if (!$@) {
		my $entry = $self->get_entry( $date, $uri->host );
		$entry->{ocurrencias} += 1;
		$entry->{trafico} += $self->get_trafico($values);
	}
}

sub get_file_name {
	return "paginas.json";
}

sub get_entry {
	my ( $self, $date, $destino ) = @_;

	if ( !exists $self->data_hash->{$date}->{$destino} ) {
		$self->data_hash->{$date}->{$destino} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$destino};
}

sub get_flattened_data {
	my ($self, $hash_ref) = @_;
	my @aaData = ();
	foreach my $destino ( keys %$hash_ref ) {
		my %entry;
		$entry{destino} = $destino;
		$entry{ocurrencias} = $hash_ref->{$destino}->{ocurrencias};
		$entry{trafico} = $hash_ref->{$destino}->{trafico};
		push @aaData, \%entry;
	}
	return \@aaData;
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
