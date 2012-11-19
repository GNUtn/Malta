package PaginasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $uri   = $self->parse_url($self->get_url($values));
	my $entry = $self->get_entry( $date, $uri->host );
	$entry->{ocurrencias} += 1;
	$entry->{trafico} += $self->get_trafico($values);
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

sub get_flatten_data {
	my ($self, $key) = @_;
	my @aaData = ();
	foreach my $destino ( keys %{ $self->data_hash->{$key} } ) {
		my %entry;
		$entry{destino} = $destino;
		$entry{ocurrencias} = $self->data_hash->{$key}->{$destino}->{ocurrencias};
		$entry{trafico} = $self->data_hash->{$key}->{$destino}->{trafico};
		push @aaData, \%entry;
	}
	return @aaData;
}

sub get_global_results {
	my ($self) = @_;
	foreach my $date ( keys %{ $self->data_hash } ) {
		foreach my $destino ( keys %{ $self->data_hash->{$date} } ) {
			if ( exists $self->data_hash->{$destino} ) {
				$self->data_hash->{$destino}->{ocurrencias} +=
				  $self->data_hash->{$date}->{$destino}->{ocurrencias};
				 $self->data_hash->{$destino}->{trafico} +=
				  $self->data_hash->{$date}->{$destino}->{trafico};
			} else {
				$self->data_hash->{$destino} = $self->data_hash->{$date}->{$destino};
			}
		}
		delete($self->data_hash->{$date});
	}
	return $self->data_hash;
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
