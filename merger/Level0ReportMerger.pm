package Level0ReportMerger;
use MooseX::Singleton;

with 'ReportMerger';
#Fuck Perl's recursion
sub merge {
	my ( $self, $orig, $new_values ) = @_;
	
	while ( my ( $key1, $vals1 ) = each %$new_values ) {
		if (exists($orig->{$key1})) {
			$self->merge_values($orig, $new_values, $key1);
		} else {
			$orig->{$key1} = $vals1;
		}
	}
}
__PACKAGE__->meta->make_immutable;
1;