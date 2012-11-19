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

sub get_flatten_data {
	my ($self, $key) = @_;
	my @aaData = ();
	foreach my $usuario ( keys %{ $self->data_hash->{$key} } ) {
		foreach my $pagina ( keys %{ $self->data_hash->{$key}->{$usuario} } ) {
			my %entry;
			$entry{usuario} = $usuario;
			$entry{pagina}  = $pagina;
			$entry{ocurrencias} = $self->data_hash->{$key}->{$usuario}->{$pagina}->{ocurrencias};
			$entry{trafico} =  $self->data_hash->{$key}->{$usuario}->{$pagina}->{trafico};
			push @aaData, \%entry;
		}
	}
	return @aaData;
}

sub get_entry {
	my ( $self, $date, $usuario, $pagina ) = @_;

	if ( !exists $self->data_hash->{$date}->{$usuario}->{$pagina} ) {
		$self->data_hash->{$date}->{$usuario}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$usuario}->{$pagina};
}

sub get_global_results {
	my ($self) = @_;
	foreach my $date ( keys %{ $self->data_hash } ) {
		foreach my $usuario ( keys %{ $self->data_hash->{$date} } ) {
			foreach my $pagina (keys %{$self->data_hash->{$date}->{$usuario}}){
				if ( exists $self->data_hash->{$usuario}->{$pagina} ) {
					$self->data_hash->{$usuario}->{$pagina}->{ocurrencias} +=
					  $self->data_hash->{$date}->{$usuario}->{$pagina}->{ocurrencias};
				} else {
					$self->data_hash->{$usuario}->{$pagina} = $self->data_hash->{$date}->{$usuario}->{$pagina};
				}
			}
		}
		delete($self->data_hash->{$date});
	}
	return $self->data_hash;
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
