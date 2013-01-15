package HostsReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(host)]});
has '+sort_field' => (default => 'trafico');
has '+file_name' => (default => 'hosts.json');

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

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = (
		peticiones      => 0,
		trafico         => 0,
		last_occurrence => Date->new(),
	);
	return \%entry;
};

override 'post_process' => sub {
	my ($self) = @_;
	super();
	while (my($date, $dates) = each %{$self->data_hash}) {
		while (my($host, $hosts) = each %$dates) {
			my $entry = $self->data_hash->{$date}->{$host};
			$entry->{last_occurrence} = $entry->{last_occurrence}->to_string('-');
		}
	}
};
__PACKAGE__->meta->make_immutable;
1;
