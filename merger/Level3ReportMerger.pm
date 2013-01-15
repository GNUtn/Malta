package Level3ReportMerger;
use MooseX::Singleton;

with 'ReportMerger';
#Fuck Perl's recursion
sub merge {
	my ( $self, $orig, $new_values ) = @_;
	
	while ( my ( $key1, $vals1 ) = each %$new_values ) {
		if (exists($orig->{$key1})) {
			while ( my ( $key2, $vals2 ) = each %$vals1 ) {
				if (exists($orig->{$key1}->{$key2})) {
					while ( my ( $key3, $vals3 ) = each %$vals2 ) {
						if (exists($orig->{$key1}->{$key2}->{$key3})) {
							while ( my ( $key4, $val ) = each %$vals3 ) {
								if (exists($orig->{$key1}->{$key2}->{$key3}->{$key4})) {
									$self->merge_values($orig->{$key1}->{$key2}->{$key3}, $vals3, $key4);
								}
							}
						} else {
							$orig->{$key1}->{$key2}->{$key3} = $vals3;
						}
					}
				} else {
					$orig->{$key1}->{$key2} = $vals2;
				}
			}
		} else {
			$orig->{$key1} = $vals1;
		}
	}
}
__PACKAGE__->meta->make_immutable;
1;