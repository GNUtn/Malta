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

sub get_level {
	return 0;
}

sub get_fields {
	return ();
}
1;
