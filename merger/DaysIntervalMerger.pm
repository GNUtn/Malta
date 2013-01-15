package DaysIntervalMerger;
use Moose;
extends 'Merger';

sub merge_interval {
	my ( $self, $date_from, $date_to ) = @_;

	my @dates_range = $self->get_dates_range( $date_from, $date_to );

	foreach my $report ( @{ $self->reports } ) {
		foreach my $date (@dates_range) {
			my $new = $self->load_values_for_date( $date, $report->get_file_name );
			$self->merge_hashes($report->data_hash, $new, $report);
		}
		$self->write_report($date_to, $report);
	}
}

sub write_report {
	my ($self, $date, $report) = @_;
	
	my $date_output_dir = $date->to_string('/') . "/";
	my $output_dir =  $self->config->output_dir . "internal/weekly/" . $date_output_dir;
		
	Hashes->store_hash( $report->data_hash, $output_dir, $report->get_file_name );
		
		
	my $aaData = $report->get_flattened_data($report->data_hash);
	$output_dir =  $self->config->output_dir . "datatables/weekly/" . $date_output_dir;
	
	$report->writer->write_top( $aaData, $report->get_sort_field, 
											$output_dir, $report->get_file_name );
}

sub get_dates_range {
	my ($self, $date_from, $date_to) = @_;
	my @dates;
	push @dates, $date_from;
	while ($dates[-1]->compare_to($date_to) < 0) {
		push @dates, $dates[-1]->get_new_plus_days(1);
	}
	push @dates, $date_to;
	return @dates;
}
__PACKAGE__->meta->make_immutable;
1;
