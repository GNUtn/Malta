package CategoriaUsuarioReportGenerator;
use Moose;
extends 'AbstractLevel2ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(categoria usuario)]});
has '+sort_field' => (default => 'ocurrencias');
has '+file_name' => (default => 'categoria_usuario.json');

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];
	
	if ($action eq 'Denied') {
		my $date = @$values[ $self->config->{fields}->{'date'} ];
		my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
		my $user = @$values[ $self->config->{fields}->{'cs-username'} ];
		my $entry = $self->get_entry( $date, $category, $user );
		$entry->{ocurrencias} += 1;
	}
}
__PACKAGE__->meta->make_immutable;
1;
