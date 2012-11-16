package ReportWriter;
use Mouse;
require 'Date.pm';
use JSON;
use File::Path qw(make_path);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig(
		config => $_[0],
	);
};

sub write {
	my ( $self, $data, $output_dir, $filename ) = @_;
	$self->create_dir($output_dir);
	my $file = $output_dir . $filename;
	open( FILEOUT, ">", $file ) or die $file, $!;
	print FILEOUT JSON->new->pretty(1)->encode($data);
	close FILEOUT;
}

sub write_report {
	my ( $self, $data_hash, $caller, $output_dir, $file_name ) = @_;
	print "Writing resutls for file: ", $file_name, "...\n";
	
	foreach my $date (keys %$data_hash) {
		
		my $date_obj = Date->new($date);
		my $date_output_dir = $date_obj->year . '/' . $date_obj->month . '/' . $date_obj->day . '/';
		
		#TODO Internally we only need global (?)
		#$self->write( $data_hash->{$date}, $output_dir . 'internal/' , $file_name );

		my @aaData = $caller->get_flatten_data($date);

		my %data = ( aaData => \@aaData );
		my $output = $output_dir . 'datatables/' . $date_output_dir;
		$self->write( \%data, $output, $file_name );

		$self->write_top( \%data, $caller->get_sort_field, $output, $file_name );
	}
	
	my $global_data = $caller->get_global_results;
	$self->write( $global_data, $output_dir . "internal/", $caller->get_file_name );
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
	my ($self, $dir) = @_;
	(make_path $dir or die "Unable to create $dir\n $!") unless -d $dir
}
1;
