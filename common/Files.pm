package Files;
use Moose;
use File::Path qw(make_path);

sub create_dir {
	my ( $class, $dir ) = @_;
	( make_path $dir or 
		Log::Log4perl->get_logger("Files")->logdie("Unable to create $dir\n $!") )
	  unless -d $dir;
}

sub list_files {
	my ( $class, $dir_path, $file_patterns ) = @_;
	my $log = Log::Log4perl->get_logger("Files");

	opendir my $dir, $dir_path or $log->logdie("Cannot open directory: $!");
	my @files = sort( grep( /$file_patterns/, readdir($dir) ) );
	closedir $dir;
	return \@files;
}
__PACKAGE__->meta->make_immutable;
1;