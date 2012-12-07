package PaginaUsuariosReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;

	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $uri   = $self->parse_url($self->get_url($values));
	eval {$uri->host; $uri->path};
	if (!$@) {
		my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
		my $entry = $self->get_entry( $date, $user, lc "http://" . $uri->host . $uri->path );
		$entry->{ocurrencias} += 1;
		$entry->{trafico} += $self->get_trafico($values);
	}
}

sub get_file_name {
	return "pagina_usuario.json";
}

sub get_flattened_data {
	my ($self, $hash_ref) = @_;
	my @aaData = ();
	foreach my $usuario ( keys %$hash_ref ) {
		foreach my $pagina ( keys %{ $hash_ref->{$usuario} } ) {
			my %entry;
			$entry{usuario} = $usuario;
			$entry{pagina}  = $pagina;
			$entry{ocurrencias} = $hash_ref->{$usuario}->{$pagina}->{ocurrencias};
			$entry{trafico} =  $hash_ref->{$usuario}->{$pagina}->{trafico};
			push @aaData, \%entry;
		}
	}
	return \@aaData;
}

sub get_entry {
	my ( $self, $date, $usuario, $pagina ) = @_;

	if ( !exists $self->data_hash->{$date}->{$usuario}->{$pagina} ) {
		$self->data_hash->{$date}->{$usuario}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$usuario}->{$pagina};
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
	my ($self) = @_;
	return 'trafico';
}
1;
