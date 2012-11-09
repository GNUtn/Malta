package HostsReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $host  = @$values[ $self->config->{fields}->{'c-ip'} ];
	my $entry = $self->get_entry($host);
	$entry->{peticiones} += 1;
	$entry->{accesos}    += 1 if $self->is_acceso($values);
	$entry->{trafico}    += @$values[ $self->config->{fields}->{'cs-bytes'} ];
	my $request_date =
	  $self->date_utils->parse_date(
		@$values[ $self->config->{fields}->{'date'} ], 'AAAA/MM/DD' );
	if (
		$self->date_utils->compare( $entry->{last_occurrence}, $request_date ) <
		0 )
	{
		$entry->{last_occurrence} = $request_date;
	}
}

sub update_totals {
	my ($self) = @_;
	foreach my $host ( keys %{ $self->data_hash } ) {
		my $entry = $self->data_hash->{$host};
		$entry->{porcentaje_peticiones} = Utils->porcentaje($entry->{peticiones}, $self->global_stats->{peticiones});
		$entry->{porcentaje_accesos}    = Utils->porcentaje($entry->{accesos}, $self->global_stats->{accesos});
		$entry->{porcentaje_trafico}    = Utils->porcentaje($entry->{trafico}, $self->global_stats->{trafico});
		$entry->{last_occurrence} = $self->date_utils->toString($entry->{last_occurrence}, 'AAAA/MM/DD', '-');
	}
}

sub get_file_name {
	return "hosts.json";
}

sub get_entry {
	my ( $self, $host ) = @_;
	if ( !exists $self->data_hash->{$host} ) {
		$self->data_hash->{$host} = $self->new_entry();
	}
	return $self->data_hash->{$host};
}

sub new_entry {
	my ( $self ) = @_;
	my %entry = (
		peticiones            => 0,
		porcentaje_peticiones => 0,
		accesos               => 0,
		porcentaje_accesos    => 0,
		trafico               => 0,
		porcentaje_trafico    => 0,
		last_occurrence       => $self->date_utils->oldest_date(),
	);
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(host)];
}
1;
