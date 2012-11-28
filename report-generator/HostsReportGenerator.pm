package HostsReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $date = @$values[ $self->config->{fields}->{'date'} ];
	my $request_date = @$values[ $self->config->{fields}->{'parsed-date'} ];
	my $host  = @$values[ $self->config->{fields}->{'c-ip'} ];
	my $entry = $self->get_entry($date, $host);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);

	if ($request_date->compare_to($entry->{last_occurrence}) < 0 ) {
		$entry->{last_occurrence} = $request_date;
	}
}

sub post_process {
	my ($self) = @_;
	foreach my $date (keys %{ $self->data_hash }) {
		foreach my $host ( keys %{ $self->data_hash->{$date} } ) {
			my $entry = $self->data_hash->{$date}->{$host};
			$entry->{last_occurrence} = $entry->{last_occurrence}->to_string;
		}
	}
}

sub get_file_name {
	return "hosts.json";
}

sub get_entry {
	my ( $self, $date, $host ) = @_;
	if ( !exists $self->data_hash->{$date}->{$host} ) {
		$self->data_hash->{$date}->{$host} = $self->new_entry();
	}
	return $self->data_hash->{$date}->{$host};
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		peticiones      => 0,
		trafico         => 0,
		last_occurrence => Date->new(),
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

sub get_sort_field {
	my ( $self ) = @_;
	return 'trafico';
}
1;
