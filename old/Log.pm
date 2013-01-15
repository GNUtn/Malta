#!/usr/bin/perl
#use strict;
#use warnings;

package Log;
use Moose;
use diagnostics;
#use MooseX::Types::DateTime ;
use DateTime;
use DateTime::Format::Strptime;
use Time::Piece;
use List::MoreUtils qw(firstidx);
use Clone;
use POSIX qw/strftime/;
use XML::Writer;
use XML::Simple;

use IO::File;
use threads; 
use Storable;

require 'Counter.pm';

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

has '_counters' => (
	is  => 'rw',
	isa => 'ArrayRef',
	default => sub { my @array; return \@array; },
	writer	=> '_set_counters'
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

sub _create_counters {    #TODO: Singleton
	my $self = shift;

	my $xml = XMLin('counters.xml', ForceArray => ['exclude', 'preprocess', 'summarizer', 'counter']);
	my @array = ();
	$self->_set_counters(\@array);
	foreach my $key (keys %{$xml->{counter}}){
		my @preprocess = ();
		my %exclude;
		my @summarizers = ();
		my %other_counters;
		foreach my $string_preprocess (@{$xml->{counter}->{$key}->{preprocess}}){
			push(@preprocess, $string_preprocess); 
		}
		foreach my $item_exclude (@{$xml->{counter}->{$key}->{exclude}}){
			$exclude{$item_exclude->{field}} = $item_exclude->{condition}; 
		}
		foreach my $summarizer (@{$xml->{counter}->{$key}->{summarizer}}){
			my %hash = ($summarizer->{summarizer_name} => $summarizer->{field});
			push(@summarizers, \%hash); 
		}
		foreach my $item_other_counters (@{$xml->{counter}->{$key}->{exclude}}){
			$other_counters{$item_other_counters->{field}} = $item_other_counters->{condition}; 
		}
		push(@{$self->_counters}, Counter->new($key,
			$xml->{counter}->{$key}->{field_index},
			\@preprocess,
			\%exclude,
			\@summarizers,
			\%other_counters
		));
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
	#$self->_load_counters_distinct();

	#TODO: prepare for zip files
	#open(FILE, "$GZIP $filezip |") || &error_exit("Error, unable to open $filezip: $!",0);
	open( my $f, $self->log_file() ) || die( "Unable to open " . $self->log_file() . ".\n" );
	$self->_set_log_filehandle($f);
	print "File " . $self->log_file() . " opened.\n";
}

sub process {
	my $self = shift;

	my $file         = $self->_log_filehandle;
	my @line_splited = [];
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
	$self->_create_counters();

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
		}
		#process minute
		if ( $self->granularity eq 'minute' ) {
			if ( $date_time->minute() != $last_date_time->minute() || $date_time->hour() != $last_date_time->hour() )
			{                                                       #TODO: add day, month and year
				threads->new( \&save_xmlT, $self, $minute_count,
					"/var/www/MaltaWeb/data/minute_" . $last_date_time->strftime( "%Y%m%d%H%M" . ".xml" ),
					'minute' );
#				$self->save_xmlT($minute_count,
#					"/var/www/MaltaWeb/data/minute_" . $last_date_time->strftime( "%Y%m%d%H%M" . ".xml" ),
#					'minute' );
				$minute_count = 1;
				$date_changed = 1;
				$self->_create_counters();
			} else {
				++$minute_count;
			}
			foreach my $counter (@{$self->_counters}){
				$counter->count(\@line_splited);
			}
		}
		if ($date_changed) {
			$date_changed   = 0;
			$last_date_time = $date_time;
		}
	}
	if ( $self->granularity eq 'minute' ) {
		threads->new( \&save_xmlT, $self, $minute_count,
			"/var/www/MaltaWeb/data/minute_" . $last_date_time->strftime( "%Y%m%d%H%M" . ".xml" ),
			'minute' );
	}
	foreach my $thr ( threads->list() ) {
		$thr->join();
	}
}

sub save_xmlT {
	my $self = shift;

	my $lines_count          = $_[0];
	my $filename             = $_[1];
	my $start_tag_name       = $_[2];
	my $doc                  = new IO::File( ">" . $filename );
	my $xml = XML::Writer->new( OUTPUT => $doc);    # || die ("\nUnable to create hours file ($file_name) in data directory.")

	$xml->xmlDecl('UTF-8');
	$xml->startTag('root');
	$xml->startTag('lines_count');
	$xml->characters($lines_count);
	$xml->endTag();
	foreach my $counter (@{$self->_counters} ) {
		$xml->startTag( $counter->name() . 's' );
		$xml->startTag( $counter->name() . 's_distincts' );
		$xml->characters( scalar (keys  %{$counter->counters} ) );
		$xml->endTag();
		my $hits_count = 0;
		foreach my $key_counters ( keys %{$counter->counters()} ) {
			$xml->startTag(
				$counter->name(), 
				'name' => $key_counters, 
				'hits' => $counter->counters()->{$key_counters}
			);
			 
			foreach my $key_summarizers (keys %{$counter->summarizers_sums->{$key_counters}}){
				$xml->startTag($key_summarizers);# 
				$xml->characters($counter->summarizers_sums->{$key_counters}->{$key_summarizers});
				$xml->endTag();
			}
			$hits_count += $counter->counters()->{$key_counters};
			$xml->endTag();
		}
		$xml->startTag( $counter->name() . 's_hits' );
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
