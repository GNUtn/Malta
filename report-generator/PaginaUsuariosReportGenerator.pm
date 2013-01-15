package PaginaUsuariosReportGenerator;
use Moose;
extends 'AbstractLevel2ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(usuario pagina)]});
has '+sort_field' => (default => 'trafico');
has '+file_name' => (default => 'pagina_usuario.json');

sub parse_values {
	my ( $self, $values ) = @_;

	my $uri = $self->parse_url( $self->get_url($values) );
	eval { $uri->host; $uri->path };
	if ( !$@ ) {
		my $date  = @$values[ $self->config->{fields}->{'date'} ];
		my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
		my $entry = $self->get_entry( $date, $user,
			lc "http://" . $uri->host . $uri->path );
		$entry->{ocurrencias} += 1;
		$entry->{trafico} += $self->get_trafico($values);
	}
}

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, trafico => 0 );
	return \%entry;
};
__PACKAGE__->meta->make_immutable;
1;
