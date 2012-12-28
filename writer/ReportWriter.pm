package ReportWriter;
use Mouse;
use JSON;

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

sub write_JSON {
	my ( $self, $data, $output_dir, $filename ) = @_;
	Files->create_dir($output_dir);
	my $file = $output_dir . $filename;
	open( FILEOUT, ">", $file ) or 
		Log::Log4perl->get_logger("ReportWriter")->logdie( $file, $! );
	print FILEOUT JSON->new->pretty(1)->encode($data);
	close FILEOUT;
}

sub write_top {
	my ( $self, $data, $sort_field, $output_dir, $file_name ) = @_;
	my $aaData = $data->{aaData};
	if ( ( scalar @$aaData ) > $self->config->top_limit ) {
		my @new = sort { $b->{$sort_field} <=> $a->{$sort_field} } @$aaData;
		@new = @new[ 0 .. $self->config->top_limit ];
		$data->{aaData} = \@new;
	}
	$self->write_JSON( $data, $output_dir, $file_name );

}

sub write_version {
	my ( $self, $dir ) = @_;
	open( VERSION, ">", $dir . "version" )
	  or Log::Log4perl->get_logger("ReportWriter")->logdie( "version", $! );
	print VERSION $self->config->version;
	close VERSION;
}
1;
