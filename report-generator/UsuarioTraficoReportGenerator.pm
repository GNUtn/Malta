package UsuarioTraficoReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
	my $entry = $self->get_entry($user);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "usuarios_trafico.json";
}

sub get_entry {
	my ( $self, $user ) = @_;
	if ( !exists $self->data_hash->{$user} ) {
		$self->data_hash->{$user} = $self->new_entry();
	}
	return $self->data_hash->{$user};
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		peticiones      => 0,
		trafico         => 0,
	);
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(usuario)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'trafico';
}
1;
