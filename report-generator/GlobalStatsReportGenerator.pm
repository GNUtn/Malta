package GlobalStatsReportGenerator;
use Moose;
extends 'AbstractReportGenerator';
require Level0ReportMerger;
with 'ReportGenerator';

has '+fields' => (default => sub {[]});
has '+sort_field' => (default => 'peticiones');
has '+file_name' => (default => 'global.json');
has '+report_merger' => (default => sub {Level0ReportMerger->instance});

sub parse_values {
	my ( $self, $values ) = @_;
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $entry = $self->get_entry($date);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_entry {
	my ( $self, $date ) = @_;

	if ( !exists $self->data_hash->{$date} ) {
		$self->data_hash->{$date} = $self->new_entry;
	}

	return $self->data_hash->{$date};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( peticiones => 0, trafico => 0 );
	return \%entry;
};

sub get_flattened_data {
	my ( $self, $hash_ref ) = @_;
	my @aaData = ();
	push @aaData, $hash_ref;
	my $aaData = { aaData => \@aaData };
	return $aaData;
}

sub get_lowest {
	my ( $self, $hash ) = @_;
	return $hash->{$self->get_sort_field};
}

sub trim_hash {
	#Do Nothing
}
__PACKAGE__->meta->make_immutable;
1;
