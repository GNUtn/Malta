package Merger;
use Mouse;

has 'reports' => (
	is  => 'rw',
	isa => 'ArrayRef'
);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

sub merge_hashes {
	my ($self, $orig, $new, $report) = @_;
	return $report->report_merger->merge( $orig, $new, $report->get_level );
}

sub load_values_for_date {
	my ($self, $date, $filename) = @_;
	return $self->load_values($self->config->output_dir . "internal/" . $date->to_string('/') . "/" . $filename);
	
}

sub load_values {
	my ($self, $file) = @_;
	return Hashes->load_hash_from_storable($file);
}
1;