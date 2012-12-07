package CategoriaUsuarioPaginaReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];

	if ( $action eq 'Denied' ) {
		my $date     = @$values[ $self->config->{fields}->{'date'} ];
		my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
		my $uri      = $self->parse_url( $self->get_url($values) );
		eval { $uri->host; $uri->path };
		if ( !$@ ) {
			my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
			my $entry = $self->get_entry( $date, $category, $user,
				lc "http://" . $uri->host . $uri->path );
			$entry->{ocurrencias} += 1;
		}
	}
}

sub get_file_name {
	return "categoria_usuario_pagina.json";
}

sub get_entry {
	my ( $self, $date, $categoria, $usuario, $pagina ) = @_;

	if ( !exists $self->data_hash->{$date}->{$categoria}->{$usuario}->{$pagina} ) {
		$self->data_hash->{$date}->{$categoria}->{$usuario}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$categoria}->{$usuario}->{$pagina};
}

sub get_flattened_data {
	my ( $self, $hash_ref ) = @_;
	my @aaData = ();
	foreach my $categoria ( keys %{$hash_ref} ) {
		foreach my $usuario ( keys %{ $hash_ref->{$categoria} } ) {
			foreach my $pagina ( keys %{ $hash_ref->{$categoria}->{$usuario} } ) {
				my %entry;
				$entry{categoria} = $categoria;
				$entry{usuario}   = $usuario;
				$entry{pagina}    = $pagina;
				$entry{ocurrencias} = $hash_ref->{$categoria}->{$usuario}->{$pagina}->{ocurrencias};
				push @aaData, \%entry;
			}
		}
	}
	return \@aaData;
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0 );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 3;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria usuario pagina)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'ocurrencias';
}
1;
