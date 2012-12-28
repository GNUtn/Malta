package UsuarioTraficoReportGenerator;
use Mouse;
extends 'ReportGenerator';

sub parse_values {
	my ( $self, $values ) = @_;
	my $user  = @$values[ $self->config->{fields}->{'cs-username'} ];
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $entry = $self->get_entry($date, $user);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "usuarios_trafico.json";
}

sub get_entry {
	my ( $self, $date, $user ) = @_;
	if ( !exists $self->data_hash->{$date}->{$user} ) {
		$self->data_hash->{$date}->{$user} = $self->new_entry();
	}
	return $self->data_hash->{$date}->{$user};
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		peticiones      => 0,
		trafico         => 0,
	);
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(usuario)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'trafico';
}
1;
