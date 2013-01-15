package UsuarioTraficoReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(usuario)]});
has '+sort_field' => (default => 'trafico');
has '+file_name' => (default => 'usuarios_trafico.json');

sub parse_values {
	my ( $self, $values ) = @_;
	my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $entry = $self->get_entry($date, $user);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = ( peticiones => 0, trafico => 0 );
	return \%entry;
};
__PACKAGE__->meta->make_immutable;
1;
