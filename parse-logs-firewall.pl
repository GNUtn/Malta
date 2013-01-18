use warnings;
use strict;
use Benchmark;
use lib 'report-generator';
use lib 'common';
use lib 'configuration';
use lib 'writer';
use lib 'parser';
use lib 'merger';
require 'Configuration.pm';
require 'Strings.pm';
require 'Parser.pm';
require 'Files.pm';
require 'Hashes.pm';
require 'ReportWriter.pm';
require 'ReportMerger.pm';
require 'ProtocolosReportGenerator.pm';
require 'Level2ReportMerger.pm';
use Log::Log4perl;
use Getopt::Std;

Log::Log4perl->init("configuration/log4perl.conf");
my $t0 = Benchmark->new;
my $conf = Configuration->instance;
my @reports = ();
our ($opt_f, $opt_w, $opt_i, $opt_o, $opt_d);
my @dates_to_parse;

parse_cmd_params('f:i:o:d:');

get_selected_reports();

my $parser = Parser->new( report_generators => \@reports);

#PArse firewall files


#-------------------------------------------------------------------
$conf->fields($conf->firewall_fields);#<-- TODO: esto es muy tricky...
#-------------------------------------------------------------------
my @files = map {$conf->log_dir.$_} @{Files->list_files($conf->log_dir, $conf->fws_file_patterns)};
$parser->parse_files(\@files, \@dates_to_parse);

my $tf = Benchmark->new;
my $td = timediff($tf, $t0);

my $log = Log::Log4perl->get_logger("main");

$log->info("Done.");
$log->info("Time elapsed: ", timestr($td));

#***************************************************************************
#***************************************************************************
#***************************************************************************


sub parse_cmd_params {
	my ($params_string) = @_;
	getopts($params_string);
	$conf->web_file_patterns('');
	$conf->fws_file_patterns($opt_f) if $opt_f;
	$conf->log_dir($opt_i) if $opt_i;
	$conf->output_dir($opt_o) if $opt_o;
	die "You must specify the dates to be parsed (-d yyyy-mm-dd,yyyy-mm-dd,...)" unless $opt_d;
	my @dates = split ',', $opt_d;
	foreach my $date (@dates) {
		push @dates_to_parse, Date->new($date);
		Log::Log4perl->get_logger("main")->debug("Added date to parse: $date");
	}
}

sub get_selected_reports {
	#TODO: Implement a configuration to select which reports to generate
	my @reports;
	push (@reports, ProtocolosReportGenerator->new);
	return @reports;
}