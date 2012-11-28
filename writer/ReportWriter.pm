package ReportWriter;
use Mouse;
require 'Date.pm';
require 'GlobalMerger.pm';
use JSON;
use File::Path qw(make_path);
use File::Slurp;

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
	my $log = Log::Log4perl->get_logger("ReportWriter");
	open( FILEOUT, ">", $file ) or $log->logdie($file, $!);
	print FILEOUT JSON->new->pretty(1)->encode($data);
	close FILEOUT;
}

sub write_report {
	my ( $self, $data_hash, $report_geneator, $output_dir, $file_name ) = @_;
	my $log = Log::Log4perl->get_logger("ReportWriter");
	
	$log->info("Writing resutls for file: ", $file_name, "...");

	foreach my $date ( keys %$data_hash ) {

		my $date_obj = Date->new($date);
		my $date_output_dir = $date_obj->year . '/' . $date_obj->month . '/' . $date_obj->day . '/';

		my @aaData = $report_geneator->get_flatten_data($date);

		my %data = ( aaData => \@aaData );
		my $output = $output_dir . 'datatables/' . $date_output_dir;
		$self->write( \%data, $output, $file_name );

		$self->write_top( \%data, $report_geneator->get_sort_field, $output, $file_name );
	}

	my $global_filename = $output_dir . 'internal/'.$file_name;
	if ( -f $global_filename ) {
		$self->update_globals( $data_hash, $report_geneator, $output_dir . 'internal/', $file_name );
	}
	else {
		$self->write(
			$report_geneator->get_global_results,
			$output_dir . "internal/",
			$report_geneator->get_file_name
		);
	}
}

sub update_globals {
	my ( $self, $data_hash, $report_geneator, $output_dir, $filename ) = @_;

	my $globals = $self->load_globals( $output_dir . $filename );
	foreach my $date ( keys %$data_hash ) {
		$report_geneator->global_merger->merge( $globals, $data_hash->{$date}, $report_geneator->get_level );
	}

	$self->write( $globals, $output_dir, $filename );

}

sub load_globals {
	my ( $self, $file ) = @_;
	my $text    = read_file($file);
	my $globals = JSON->new->decode($text);
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
	$self->write( $data, $output_dir . 'top/', $file_name );

}

sub create_dir {
	my ( $self, $dir ) = @_;
	my $log = Log::Log4perl->get_logger("ReportWriter");
	( make_path $dir or $log->logdie("Unable to create $dir\n $!") ) unless -d $dir;
}
1;
