package CategoriaUsuariosReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];
	
	if ($action eq 'Denied') {
		my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
		my $url   = @$values[ $self->config->{fields}->{'cs-uri'} ];
		my $uri   = $self->parse_url($url);
		my $user = @$values[ $self->config->{fields}->{'cs-username'} ];
		my $entry = $self->get_entry( $category, $user, "http://".$uri->host.$uri->path );
		$entry->{ocurrencias} += 1;
	}
}

sub get_file_name {
	return "categoria_usuario.json";
}

sub get_entry {
	my ( $self, $categoria, $usuario, $pagina ) = @_;

	if ( !exists $self->data_hash->{$categoria}->{$usuario}->{$pagina} ) {
		$self->data_hash->{$categoria}->{$usuario}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$categoria}->{$usuario}->{$pagina};
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
	return 3;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria usuario pagina)];
}
1;
