package PaginaUsuariosReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;

	my $url   = @$values[ $self->config->{fields}->{'cs-uri'} ];
	my $uri   = $self->parse_url($url);
	my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
	my $entry = $self->get_entry( $user, "http://" . $uri->host . $uri->path );
	$entry->{ocurrencias} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "pagina_usuario.json";
}

sub write_report {
	my ( $self, $output_dir ) = @_;

	$self->writer->write( $self->data_hash, $output_dir . 'internal/',
		$self->get_file_name );

	my @aaData = ();
	foreach my $usuario ( keys %{ $self->data_hash } ) {
		foreach my $pagina ( keys %{ $self->data_hash->{$usuario} } ) {
			my %entry;
			$entry{usuario} = $usuario;
			$entry{pagina}  = $pagina;
			$entry{ocurrencias} =
			  $self->data_hash->{$usuario}->{$pagina}->{ocurrencias};
			$entry{trafico} = $self->data_hash->{$usuario}->{$pagina}->{trafico};
			push @aaData, \%entry;
		}
	}
	my %data = ( aaData => \@aaData );
	$self->writer->write( \%data, $output_dir . 'datatables/',
		$self->get_file_name );
	
	$self->write_top(\%data, $output_dir);
}

sub get_entry {
	my ( $self, $usuario, $pagina ) = @_;

	if ( !exists $self->data_hash->{$usuario}->{$pagina} ) {
		$self->data_hash->{$usuario}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$usuario}->{$pagina};
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		ocurrencias => 0,
		trafico     => 0
	);
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(usuario pagina)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'trafico';
}
1;
