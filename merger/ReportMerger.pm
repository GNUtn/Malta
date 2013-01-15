package ReportMerger;
use Moose::Role;

requires qw(merge);

sub merge_values {
	my ($self, $orig, $new, $key) = @_;
	$orig->{$key} += $new->{$key};
}
1;
