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
#require 'HostsReportGenerator.pm';
require 'GlobalStatsReportGenerator.pm';
require 'PaginasReportGenerator.pm';
require 'StatusReportGenerator.pm';
require 'CategoriasReportGenerator.pm';
require 'CategoriaUsuarioReportGenerator.pm';
require 'CategoriaUsuarioPaginaReportGenerator.pm';
require 'SearchReportGenerator.pm';
require 'UsuarioTraficoReportGenerator.pm';
require 'PaginaUsuariosReportGenerator.pm';
require 'ReportWriter.pm';
require 'ReportMerger.pm';
require 'StatusReportMerger.pm';
require 'DescargasReportGenerator.pm';
require 'ProtocolosReportGenerator.pm';
require 'SimpleReportGenerator.pm';
require 'BrowserReportGenerator.pm';
require 'NoCategorizadosReportGenerator.pm';
use Log::Log4perl;
use Getopt::Std;

Log::Log4perl->init("configuration/log4perl.conf");
my $t0 = Benchmark->new;
my $conf = Configuration->new;
my $writer = ReportWriter->new(config => $conf);
my $report_merger = ReportMerger->new;
my @reports = ();
our ($opt_f, $opt_w, $opt_i, $opt_o, $opt_d);
my @dates_to_parse;

parse_cmd_params('w:f:i:o:d:');

get_selected_reports();

my $parser = Parser->new( report_generators => \@reports, config => $conf);
my @files = map {$conf->log_dir.$_} @{Files->list_files($conf->log_dir, $conf->web_file_patterns)};

$parser->parse_files(\@files, \@dates_to_parse);

$writer->write_version($conf->output_dir);

#PArse firewall files

undef @reports;
push (@reports, ProtocolosReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
#-------------------------------------------------------------------
$conf->fields($conf->firewall_fields);#<-- TODO: esto es muy tricky...
#-------------------------------------------------------------------
@files = map {$conf->log_dir.$_} @{Files->list_files($conf->log_dir, $conf->fws_file_patterns)};
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
	$conf->web_file_patterns($opt_w) if $opt_w;
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
	
	push (@reports, GlobalStatsReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	#push (@reports, HostsReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, PaginasReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, StatusReportGenerator->new(config => $conf, writer => $writer, report_merger => StatusReportMerger->new()));
	push (@reports, CategoriasReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, CategoriaUsuarioReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, CategoriaUsuarioPaginaReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, SearchReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, UsuarioTraficoReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, PaginaUsuariosReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, DescargasReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	push (@reports, NoCategorizadosReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger));
	# Browsers report
	push (@reports, BrowserReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger, 
													field => 'c-agent', file_name => 'browsers.json'));
	
	# Clientes unicos
	push (@reports, SimpleReportGenerator->new(config => $conf, writer => $writer, report_merger => $report_merger,
													field => 'cs-username', file_name => 'clients.json' ));
}