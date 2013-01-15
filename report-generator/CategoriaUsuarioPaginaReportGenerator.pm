package CategoriaUsuarioPaginaReportGenerator;
use Moose;
extends 'AbstractReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(categoria usuario pagina)]});
has '+sort_field' => (default => 'ocurrencias');
has '+file_name' => (default => 'categoria_usuario_pagina.json');
has '+report_merger' => (default => sub {Level3ReportMerger->instance});

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

sub get_entry {
	my ( $self, $date, $categoria, $usuario, $pagina ) = @_;

	if (!exists $self->data_hash->{$date}->{$categoria}->{$usuario}->{$pagina} ) {
		$self->data_hash->{$date}->{$categoria}->{$usuario}->{$pagina} =
		  $self->new_entry;
	}

	return $self->data_hash->{$date}->{$categoria}->{$usuario}->{$pagina};
}

sub get_flattened_data {
	my ( $self, $hash_ref ) = @_;
	my @aaData = ();
	while ( my ( $categoria, $cat ) = each %$hash_ref ) {
		while ( my ( $usuario, $usr ) = each %$cat ) {
			while ( my ( $pagina, $vals ) = each %$usr ) {
				my %entry;
				$entry{categoria}   = $categoria;
				$entry{usuario}     = $usuario;
				$entry{pagina}      = $pagina;
				$entry{ocurrencias} = $vals->{ocurrencias};
				push @aaData, \%entry;
			}
		}
	}
	my $aaData = { aaData => \@aaData };
	return $aaData;
}

sub get_lowest {
	my ( $self, $hash ) = @_;
	my @vals = ();
	while ( my ( $key1, $vals1 ) = each %$hash ) {
		while ( my ( $key2, $vals2 ) = each %$vals1 ) {
			while ( my ( $key3, $vals3 ) = each %$vals2 ) {
				push @vals, $vals3->{$self->get_sort_field};
			}
		}
	}
	if ( scalar @vals > $self->config->globals_limit ) {
		@vals = sort(@vals[ 0 .. $self->config->globals_limit ]);
		return $vals[-1];
	} else {
		return undef;
	}
}

sub trim_hash {
	my ($self, $hash_ref, $lowest_val) = @_;
	
	while ( my ( $categoria, $cat ) = each %$hash_ref ) {
		while ( my ( $usuario, $usr ) = each %$cat ) {
			while ( my ( $pagina, $vals ) = each %$usr ) {
				delete $hash_ref->{$categoria}->{$usuario}->{$pagina} if($vals->{$self->get_sort_field} <= $lowest_val);
			}
			delete $hash_ref->{$categoria}->{$usuario} if (scalar keys %$usr <= 0);
		}
		delete $hash_ref->{$categoria} if (scalar keys %$cat <= 0);
	}
}
__PACKAGE__->meta->make_immutable;
1;
