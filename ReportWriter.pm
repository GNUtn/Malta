package ReportWriter;
use Mouse;
use JSON;

sub write {
	my ( $self, $data, $output_dir, $filename ) = @_;
	my $file = $output_dir . $filename;
	open( FILEOUT, ">", $file ) or die $file, $!;
	print FILEOUT JSON->new->pretty(1)->encode($data);
	close FILEOUT;
}
1;
