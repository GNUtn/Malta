package StatusGlobalMerger;
use Mouse;
extends 'GlobalMerger';

sub merge_values {
	my ($self, $orig, $new, $key) = @_;
	if ($key ne 'descripcion') {
		$orig->{$key} += $new->{$key};
	}
}
1;