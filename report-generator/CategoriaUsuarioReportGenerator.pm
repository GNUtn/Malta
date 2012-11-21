package CategoriaUsuarioReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];
	
	if ($action eq 'Denied') {
		my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
		my $user = @$values[ $self->config->{fields}->{'cs-username'} ];
		my $entry = $self->get_entry( $category, $user );
		$entry->{ocurrencias} += 1;
	}
}

sub get_file_name {
	return "categoria_usuario.json";
}

sub get_entry {
	my ( $self, $categoria, $usuario ) = @_;

	if ( !exists $self->data_hash->{$categoria}->{$usuario} ) {
		$self->data_hash->{$categoria}->{$usuario} = $self->new_entry;
	}

	return $self->data_hash->{$categoria}->{$usuario};
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		ocurrencias => 0
	);
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria usuario)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'ocurrencias';
}
1;
