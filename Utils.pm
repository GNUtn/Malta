package Utils;
use Mouse;

sub get_files_list {
	my ( $class, $dir_path ) = @_;

	opendir my $dir, $dir_path or die "Cannot open directory: $!";
	my @files = sort(grep(!/^(\.|\.\.)$/, readdir($dir)));
	closedir $dir;
	return \@files;
}

sub rstrip {
	my ( $class, $line ) = @_;
	chop($line);
	$line =~ s/\s+$//;
	return $line;
}
1;