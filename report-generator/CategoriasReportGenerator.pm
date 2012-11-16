package CategoriasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $action   = @$values[ $self->config->{fields}->{'action'} ];
	my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
	if ( $action eq 'Denied' ) {
		my $entry = $self->get_entry($category);
		$entry->{ocurrencias} += 1;
	}
}

sub get_file_name {
	return "categorias.json";
}

sub get_entry {
	my ( $self, $categoria ) = @_;

	if ( !exists $self->data_hash->{$categoria} ) {
		$self->data_hash->{$categoria} = $self->new_entry;
	}

	return $self->data_hash->{$categoria};
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
	my ( $self ) = @_;
	return 'ocurrencias';
}
1;
