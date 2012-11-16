package GlobalStatsReportGenerator;
use Mouse;
extends 'ReportGenerator';

sub parse_values {
	my ( $self, $values ) = @_;
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $entry = $self->get_entry($date);
	$entry->{peticiones} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_global_results {
	my ($self) = @_;
	$self->data_hash->{peticiones}  = 0;
	$self->data_hash->{trafico}  = 0;
	foreach my $date (keys %{$self->data_hash}) {
		if ($date ne 'peticiones' && $date ne 'trafico') {
			$self->data_hash->{peticiones} += $self->data_hash->{$date}->{peticiones};
			$self->data_hash->{trafico} += $self->data_hash->{$date}->{trafico};
			delete $self->data_hash->{$date};
		}
	}
	return $self->data_hash;
}

sub get_flatten_data {
	my ($self, $key) = @_;
	my @aaData = ( $self->data_hash->{$key} );
	return @aaData;
}

sub get_file_name {
	return "global.json";
}

sub get_sort_field {
	my ($self) = @_;
	return 'peticiones';
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
}
1;
