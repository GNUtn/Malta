package StatusReportMerger;
use Moose;
extends 'Level2ReportMerger';

override 'merge_values' => sub {
	my ($self, $orig, $new, $key) = @_;
	if ($key ne 'descripcion') {
		$orig->{$key} += $new->{$key};
	}
};
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;