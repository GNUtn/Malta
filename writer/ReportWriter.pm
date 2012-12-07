package ReportWriter;
use Mouse;
require 'Date.pm';
require 'GlobalMerger.pm';
require 'DataHashFlatten.pm';
use JSON;
use File::Path qw(make_path);
use File::Slurp;

#TODO: This class needs refactor!

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig( config => $_[0], );
};

sub write {
	my ( $self, $data, $output_dir, $filename ) = @_;
	$self->create_dir($output_dir);
	my $file = $output_dir . $filename;
	open( FILEOUT, ">", $file ) or 
		Log::Log4perl->get_logger("ReportWriter")->logdie( $file, $! );
	print FILEOUT JSON->new->pretty(1)->encode($data);
	close FILEOUT;
}

sub write_report {
	my ( $self, $data_hash, $report_generator, $output_dir, $file_name ) = @_;
	my $logger = Log::Log4perl->get_logger("ReportWriter");
	
	$logger->info( "Writing resutls for file: ", $file_name, "..." );

	foreach my $date ( keys %$data_hash ) {

		my $date_obj = Date->new($date);
		my $date_output_dir = $date_obj->year . '/' . $date_obj->month . '/' . $date_obj->day . '/';
		
		$logger->debug("Flattening data");
		my $aaData = $report_generator->get_flattened_data($data_hash->{$date});

		my %data = ( aaData => $aaData );

		$self->write_top( \%data, $report_generator->get_sort_field, $output_dir . 'datatables/' . $date_output_dir, $file_name );
	}

	$self->update_globals( $data_hash, $report_generator, $output_dir, $file_name );
}

sub update_globals {
	my ( $self, $data_hash, $report_generator, $output_dir, $filename ) = @_;

	Log::Log4perl->get_logger("ReportWriter")->debug("Updating globals");
	my $globals = $self->load_globals( $output_dir . "internal/" . $filename );
	foreach my $date ( keys %$data_hash ) {
		$report_generator->global_merger->merge( $globals, $data_hash->{$date}, $report_generator->get_level );
	}

	$self->write( $globals, $output_dir . "internal/", $filename );
	
#	my $aaData = $report_generator->get_flattened_data;
#	
#	my %data = ( aaData => $aaData );
#	$self->write_top( \%data, $report_generator->get_sort_field, $output_dir."datatables/", $filename );

}

sub load_globals {
	my ( $self, $file ) = @_;
	my $globals = {};
	if ( -f $file ) {
		my $text = read_file($file);
		$globals = JSON->new->decode($text);
	}
	return $globals;
}

sub write_top {
	my ( $self, $data, $sort_field, $output_dir, $file_name ) = @_;
	my $aaData = $data->{aaData};
	if ( ( scalar @$aaData ) > $self->config->top_limit ) {
		my @new = sort { $b->{$sort_field} <=> $a->{$sort_field} } @$aaData;
		@new = @new[ 0 .. $self->config->top_limit ];
		$data->{aaData} = \@new;
	}
	$self->write( $data, $output_dir, $file_name );

}

sub write_version {
	my ( $self, $dir ) = @_;
	open( VERSION, ">", $dir . "version" )
	  or Log::Log4perl->get_logger("ReportWriter")->logdie( "version", $! );
	print VERSION $self->config->version;
	close VERSION;
}

sub create_dir {
	my ( $self, $dir ) = @_;
	( make_path $dir or 
		Log::Log4perl->get_logger("ReportWriter")->logdie("Unable to create $dir\n $!") )
	  unless -d $dir;
}
1;
