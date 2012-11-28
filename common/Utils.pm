package Utils;
use Mouse;

sub get_files_list {
	my ( $class, $dir_path, $file_patterns ) = @_;
	my $log = Log::Log4perl->get_logger("Utils");

	opendir my $dir, $dir_path or $log->logdie("Cannot open directory: $!");
	my @files = sort( grep( /$file_patterns/, readdir($dir) ) );
	closedir $dir;
	return \@files;
}

sub rstrip {
	my ( $class, $line ) = @_;
	chop($line);
	$line =~ s/\s+$//;
	return $line;
}

sub porcentaje {
	my ( $class, $part, $total ) = @_;
	return ( 100 * $part ) / $total;
}
1;
