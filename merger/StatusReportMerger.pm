package StatusReportMerger;
use Mouse;
extends 'ReportMerger';

sub merge_values {
	my ($self, $orig, $new, $key) = @_;
	if ($key ne 'descripcion') {
		$orig->{$key} += $new->{$key};
	}
}
1;