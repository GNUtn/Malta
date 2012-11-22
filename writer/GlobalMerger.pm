package GlobalMerger;
use Mouse;

sub merge {
	my ($self, $orig, $new_values, $level, $depth) = @_;
	$depth = 0 unless defined($depth);
	
	foreach my $key (keys %$new_values) {
		if (exists $orig->{$key}) {
			if ($level > $depth) {
				$self->merge($orig->{$key}, $new_values->{$key}, $level, $depth +1);
			} else {
				$self->merge_values($orig, $new_values, $key);
			}
		} else {
			$orig->{$key} = $new_values->{$key};
		}
	}
}

sub merge_values {
	my ($self, $orig, $new, $key) = @_;
	$orig->{$key} += $new->{$key};
}
1;