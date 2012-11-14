#!/usr/bin/perl
#use strict;
#use warnings;

package Log;
use Mouse;

#use MooseX::Types::DateTime ;
use DateTime;
use DateTime::Format::Strptime;
use Time::Piece;
use List::MoreUtils qw(firstidx);
use Clone;
use POSIX qw/strftime/;
use XML::Writer;
use IO::File;
use threads;
use Storable;

# rw properties
has 'log_file' => (
	is  => 'rw',
	isa => 'Str'
);

has 'structure' => (
	is  => 'rw',
	isa => 'ArrayRef'
);

has 'skip_lines' => (
	is      => 'rw',
	isa     => 'Int',
	default => 0
);

has 'separator' => (
	is      => 'rw',
	isa     => 'Str',
	default => '\t'
);

has 'date_format' => (
	is      => 'rw',
	isa     => 'Str',
	default => '%Y-%m-%d'
);

has 'time_format' => (
	is      => 'rw',
	isa     => 'Str',
	default => '%H:%M:%S'
);

has 'granularity' => (
	is      => 'rw',
	isa     => 'Str',
	default => 'minute'
);

# ro properties

has '_log_filehandle' => (
	is     => 'ro',
	isa    => 'FileHandle',
	writer => '_set_log_filehandle'
);

# Cantidad de lineas leidas del log
has 'lines_readed' => (
	is      => 'ro',
	isa     => 'Int',
	writer  => '_set_lines_readed',
	default => 0
);

#Cantidad de lineas procesadas
has 'lines_processed' => (
	is      => 'ro',
	isa     => 'Int',
	writer  => '_set_lines_processed',
	default => 0
);

#private properties
has '_filters' => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub { my %hash; return \%hash; }
);

has '_counters_distincts_indexes' => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub { my %hash; return \%hash; }
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig(
		log_file    => $_[0],
		skip_lines  => $_[1],
		structure   => $_[2],
		granularity => $_[3]
	);
};

sub BUILD {
	my $self = shift;

	return 1;
}

# private methods

sub _load_filters {
	my $self = shift;

	open( my $file_filters, "filters.txt" ) || die("Unable to open filters file \"filters.txt\".");
	while ( my $line = <$file_filters> ) {
		chomp($line);
		my @array = split( $self->separator, $line );
		my $h     = $self->_filters();
		my $index = firstidx { $_ eq $array[0] } @{ $self->structure };
		$h->{$index} = $array[1];
	}
}

sub _load_counters_distinct {
	my $self = shift;

	open( my $file, "countersDistinct.txt" ) || die("Unable to open filters file \"countersDistinct.txt\".");
	while ( my $line = <$file> ) {
		next if ( $line =~ /^#/i );                          	#TODO: set comment char in configuration
		chomp($line);											#TODO: paste counterdistinct to object
		my @array = split( $self->separator, $line );
		my $h     = $self->_counters_distincts_indexes();
		my $index = firstidx { $_ eq $array[1] } @{ $self->structure };
		my $indexExclude;
		my $indexSumarize; 
		if ($array[3]){
			$indexExclude = firstidx { $_ eq $array[3] } @{ $self->structure };
		}
		if ($array[5]){
			$indexSumarize = firstidx { $_ eq $array[5] } @{ $self->structure };
		}
		#campos del array: indice del campo a buscar, preprosesar, indice del campo a excluir, regex de exclusion, indice del campo a sumarizar
		$h->{ $array[0] } = [ $index, $array[2], $indexExclude, $array[4], $indexSumarize ];
	}
}

# Analiza la línea y devuelve si filtrada (procesada) o no
sub _filter {
	my $self = shift;

	my $refArr       = $_[0];
	my @line         = @{$refArr};               #array with fields of the line of the log
	my %hash_filters = %{ $self->_filters() };
	foreach my $index ( keys %hash_filters ) {    # for each filter
		if ( $hash_filters{'1'} ne "" ) {
			if ( $line[$index] =~ /$hash_filters{'1'}/i ) {    #TODO: case sesitive for configuration
				return 1;
			}
		}
	}
	return 0;
}

# public methods
sub open_log {
	my $self = shift;

	$self->_load_filters();
	$self->_load_counters_distinct();

	#TODO: prepare for zip files
	#open(FILE, "$GZIP $filezip |") || &error_exit("Error, unable to open $filezip: $!",0);
	open( my $f, $self->log_file() ) || die( "Unable to open " . $self->log_file() . ".\n" );
	$self->_set_log_filehandle($f);
	print "File " . $self->log_file() . " opened.\n";
}

sub process {
	my $self = shift;

	my $file         = $self->_log_filehandle;
	my @line_splited = ();
	my $line_readed  = "";

	my $date_index = firstidx { $_ eq 'date' } @{ $self->structure };
	my $time_index = firstidx { $_ eq 'time' } @{ $self->structure };
	my $structure_length = scalar( @{ $self->structure } );
	my $last_date_time   = DateTime->new(
		year   => 1900,
		day    => 1,
		month  => 1,
		hour   => 0,
		minute => 0,
		second => 0
	);

	my $year_count  = 0;
	my $month_count = 0;
	my $day_count   = 0;
	my $hour_count;
	my $minute_count = 0;
	my $date_changed = 0;
	my $format       = new DateTime::Format::Strptime(
		pattern   => $self->date_format() . $self->time_format(),
		locale    => 'es_AR',
		time_zone => 'GMT'                                          #TODO: paste to config
	);
	my $date_time;
	my $counter_distinct_minute = $self->_create_hash_counter_distinct();
	my $counter_distinct_hour   = $self->_create_hash_counter_distinct();
	my $counter_distinct_totals = $self->_create_hash_counter_distinct();

	while (<$file>) { last if ( $. == $self->skip_lines ) }         #skip lines
	while ( $line_readed = <$file> ) {
		$self->_set_lines_readed( $self->lines_readed + 1 );
		next if ( $line_readed =~ /^#/i );                          #TODO: set comment char in configuration
		chomp($line_readed);
		@line_splited = split( $self->separator, $line_readed );
		if ( scalar(@line_splited) < $structure_length ) {
			print "\nLine " . $self->lines_readed . " haven't the necessary number of fields";
			next;
		}
		next if ( $self->_filter( \@line_splited ) );               # filtro registros
		$self->_set_lines_processed( $self->lines_processed + 1 );
		$date_time = $format->parse_datetime( $line_splited[$date_index] . $line_splited[$time_index] );
		if ( $self->lines_processed == 1 ) {                        #first line process
			$last_date_time = $date_time;                           #TODO: cambiar para leer archivo de estado, poner antes del while
			$minute_count   = 1;
			$hour_count     = 1;
			%{$counter_distinct_totals} = ();
			$self->_update_counters_distincts( \@line_splited, $counter_distinct_totals );
		}
		
		#$self->_preprocess_line(\@line_splited);
		#process minute
		if ( $self->granularity eq 'minute' ) {
			if ( $date_time->minute() != $last_date_time->minute() || $date_time->hour() != $last_date_time->hour() )
			{                                                       #TODO: add day, month and year
				threads->new( \&save_xmlT, $minute_count, "/var/www/MaltaWeb/data/minute_" . $last_date_time->strftime( "%Y%m%d%H%M" . ".xml" ),
					$counter_distinct_minute, 'minute' );
				$minute_count = 1;
				$date_changed = 1;
				%{$counter_distinct_minute} = ();
			} else {
				++$minute_count;
			}
			$self->_update_counters_distincts( \@line_splited, $counter_distinct_minute );
		}

		#process hour
		if ( $self->granularity eq 'minute' || $self->granularity eq 'hour' ) {
			if ( $date_time->hour() != $last_date_time->hour() ) {

				#				threads->new(\&merge_xmlT, 'hour', $last_date_time->strftime("%Y%m%d%H"));
				threads->new( \&save_xmlT, $hour_count, "/var/www/MaltaWeb/data/hour_" . $last_date_time->strftime( "%Y%m%d%H" . ".xml" ),
					$counter_distinct_hour, 'hour' );
				$hour_count   = 1;
				$date_changed = 1;
				%{$counter_distinct_hour} = ();
			} else {				
				++$hour_count;
			}
			$self->_update_counters_distincts( \@line_splited, $counter_distinct_hour );
		}
		#process totals
		$self->_update_counters_distincts(\@line_splited, $counter_distinct_totals);
		if ($date_changed) {
			$date_changed   = 0;
			$last_date_time = $date_time;
		}
	}
	if ( $self->granularity eq 'minute' ) {
		threads->new( \&save_xmlT, $minute_count, "/var/www/MaltaWeb/data/minute_" . $last_date_time->strftime( "%Y%m%d%H%M" . ".xml" ),
			$counter_distinct_minute, 'minute' );
	}

	if ($self->granularity eq 'minute' || $self->granularity eq 'hour'){
		threads->new(\&save_xmlT, $hour_count , "/var/www/MaltaWeb/data/hour_" . $last_date_time->strftime("%Y%m%d%H" . ".xml") , $counter_distinct_hour, 'hour');
	}
	threads->new(\&save_xmlT, $self->lines_processed() , "/var/www/MaltaWeb/data/totals.xml" , $counter_distinct_totals, 'totals');
	foreach my $thr ( threads->list() ) {
		$thr->join();
	}
}

sub _preprocess_field{
	my $self = shift;
	my $value = shift;
	my $key = shift;
	
	if (${ $self->_counters_distincts_indexes() }{$key}[1]){
		foreach my $regex (split(' ', ${ $self->_counters_distincts_indexes() }{$key}[1])){
			my $code ="";
			$code = '$value =~ ' . $regex . ';';
			eval ($code);	
		}
		
	}
	return $value;
}

sub _update_counters_distincts {
	my $self = shift;

	my @line_splited     = @{ $_[0] };
	my $counter_distinct = $_[1];
	my $value_exclude = "";
	my $value_field = "";
	foreach my $counter_key ( keys %{ $self->_counters_distincts_indexes() } ) {
		$value_field = $self->_preprocess_field($line_splited[ ${ $self->_counters_distincts_indexes() }{$counter_key}[0] ], $counter_key);
		if ( ${ $self->_counters_distincts_indexes() }{$counter_key}[2] && ${ $self->_counters_distincts_indexes() }{$counter_key}[3] ){# if ExcludeByField	is applied
			$value_exclude = $self->_preprocess_field($line_splited[ ${ $self->_counters_distincts_indexes() }{$counter_key}[2] ], $counter_key);
			if(!($value_exclude =~ m/${ $self->_counters_distincts_indexes() }{$counter_key}[3]/i)){
				$counter_distinct->{$counter_key}->{ $value_field }[0] += 1;
			}
		}else{
			$counter_distinct->{$counter_key}->{ $value_field }[0] += 1;
		}
	}
}

sub _create_hash_counter_distinct {    #TODO: Singleton
	my $self = shift;

	my %hash;
	foreach my $key ( keys %{ $self->_counters_distincts_indexes() } ) {
		$hash{$key} = {};
	}
	return \%hash;
}

sub merge_xmlT {
	my $type = $_[0];
	my $hour = $_[1];

	my @files     = [];
	my $count_str = "";
	my $input_file;
	my $file;

	open my $file_merge, "/var/www/MaltaWeb/data/hour_" . $hour . ".xml";
	if ( $type eq 'hour' ) {
		my $count;
		for $count ( 0 .. 59 ) {
			$count_str  = "" . $count;
			$input_file = "/var/www/MaltaWeb/data/minute_" . $hour . "$count_str.xml";
			$count_str  = "0" . $count if ( $count < 10 );
			if ( -e $input_file ) {
				open $files[$count], "<$input_file" or die $!;
			} else {
				last;
			}
		}
		my @datos = [];
		while (1) {
			$count = 0;
			foreach $file (@files) {
				$datos[$count] = <$file>;
			}
		}
		foreach $file (@files) {
			close $file;
		}
	}

}

sub save_xmlT {    
	my $lines_count          = $_[0];
	my $filename             = $_[1];
	my $ref_counter_distinct = $_[2];
	my $start_tag_name       = $_[3];
	my $doc                  = new IO::File( ">" . $filename );
	my $xml = XML::Writer->new( OUTPUT => $doc, DATA_MODE => 1 );    # || die ("\nUnable to create hours file ($file_name) in data directory.")

	$xml->xmlDecl('UTF-8');
	$xml->startTag('root');
	$xml->startTag('lines_count');
	$xml->characters($lines_count);
	$xml->endTag();
	foreach my $key1 ( sort keys %{$ref_counter_distinct} ) {
		$xml->startTag( $key1 . 's' );
		$xml->startTag( $key1 . 's_distincts' );
		$xml->characters( scalar( keys %{ $ref_counter_distinct->{$key1} } ) );
		$xml->endTag();
		my $hits_count = 0;
		foreach my $key2 ( sort keys %{ $ref_counter_distinct->{$key1} } ) {
			my $hits = $ref_counter_distinct->{$key1}->{$key2}[0];
			$xml->startTag( $key1, 'name' => $key2, 'hits' => $hits );
			$hits_count += $hits;
			$xml->endTag();
		}
		$xml->startTag( $key1 . 's_hits' );
		$xml->characters($hits_count);
		$xml->endTag();
		$xml->endTag();
	}
	$xml->endTag();
	$xml->end();
	$doc->close();
	print "\nProcesado $start_tag_name ";
	return 1;
}

sub close {
	my $self = shift;

	close( $self->_log_filehandle );
}

__PACKAGE__->meta->make_immutable;
1;

__END__
