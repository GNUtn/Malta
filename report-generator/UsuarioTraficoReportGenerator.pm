package UsuarioTraficoReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $entry = $self->get_entry($date, $user);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "usuarios_trafico.json";
}

sub get_entry {
	my ( $self, $date, $user ) = @_;
	if ( !exists $self->data_hash->{$date}->{$user} ) {
		$self->data_hash->{$date}->{$user} = $self->new_entry();
	}
	return $self->data_hash->{$date}->{$user};
}

sub get_global_results {
	my ($self) = @_;
	foreach my $date ( keys %{ $self->data_hash } ) {
		foreach my $usuario ( keys %{ $self->data_hash->{$date} } ) {
			if ( exists $self->data_hash->{$usuario} ) {
				$self->data_hash->{$usuario}->{peticiones} +=
				  $self->data_hash->{$date}->{$usuario}->{peticiones};
				$self->data_hash->{$usuario}->{trafico} +=
				  $self->data_hash->{$date}->{$usuario}->{trafico};
			} else {
				$self->data_hash->{$usuario} = $self->data_hash->{$date}->{$usuario};
			}
			delete($self->data_hash->{$date}->{$usuario});
		}
		delete($self->data_hash->{$date});
	}
	return $self->data_hash;
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
