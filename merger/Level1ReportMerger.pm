package Level1ReportMerger;
use MooseX::Singleton;

with 'ReportMerger';
#Fuck Perl's recursion
sub merge {
	my ( $self, $orig, $new_values ) = @_;
	
	while ( my ( $key1, $vals1 ) = each %$new_values ) {
		if (exists($orig->{$key1})) {
			while ( my ( $key2, $val ) = each %$vals1 ) {
				if (exists($orig->{$key1}->{$key2})) {
					$self->merge_values($orig->{$key1}, $vals1, $key2);
				}
			}
		} else {
			$orig->{$key1} = $vals1;
		}
	}
}
__PACKAGE__->meta->make_immutable;
1;