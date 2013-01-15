package Hashes;
use Moose;
use Storable;

sub load_hash_from_storable {
	my ( $class, $file ) = @_;
	my $hash = {};
	if ( -f $file ) {
		$hash = retrieve($file);
	}
	return $hash;
}

sub store_hash {
	my ( $class, $hash, $output_dir, $filename ) = @_;
	Files->create_dir($output_dir);
	store $hash, $output_dir . $filename;
}
__PACKAGE__->meta->make_immutable;
1;