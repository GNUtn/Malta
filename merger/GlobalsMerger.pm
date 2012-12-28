package GlobalsMerger;
use Mouse;
extends 'Merger';

sub merge_globals {
	my ($self, $date) = @_;
	foreach my $report ( @{ $self->reports } ) {
		my $globals = $self->load_values($self->config->output_dir . "internal/" . $report->get_file_name);
		my $new = $self->load_values_for_date($date, $report->get_file_name);
		
		$self->merge_hashes($globals, $new, $report);
		$self->write_report($globals, $report);
	}
}

sub write_report {
	my ($self, $hash, $report) = @_;
	
	Hashes->store_hash( $hash, $self->config->output_dir . "internal/", $report->get_file_name );

	my $aaData = $report->get_flattened_data($hash);
	my $output_dir =  $self->config->output_dir . "datatables/";
	
	$report->writer->write_top( $aaData, $report->get_sort_field, $output_dir, $report->get_file_name );
}
1;
