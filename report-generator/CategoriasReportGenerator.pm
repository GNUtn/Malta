package CategoriasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

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

sub get_file_name {
	return "categorias.json";
}

sub get_entry {
	my ( $self, $date, $categoria ) = @_;

	if ( !exists $self->data_hash->{$date}->{$categoria} ) {
		$self->data_hash->{$date}->{$categoria} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$categoria};
}

sub get_global_results {
	my ($self) = @_;
	foreach my $date ( keys %{ $self->data_hash } ) {
		foreach my $categoria ( keys %{ $self->data_hash->{$date} } ) {
			if ( exists $self->data_hash->{$categoria} ) {
				$self->data_hash->{$categoria}->{ocurrencias} +=
				  $self->data_hash->{$date}->{$categoria}->{ocurrencias};
			} else {
				$self->data_hash->{$categoria} = $self->data_hash->{$date}->{$categoria};
			}
			delete($self->data_hash->{$date}->{$categoria});
		}
		delete($self->data_hash->{$date});
	}
	return $self->data_hash;
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'ocurrencias';
}
1;
