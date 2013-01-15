use warnings;
use strict;
use Benchmark;
use lib 'report-generator';
use lib 'common';
use lib 'configuration';
use lib 'writer';
use lib 'merger';
require 'Configuration.pm';
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
require 'DaysIntervalMerger.pm';
require 'Level0ReportMerger.pm';
require 'Level1ReportMerger.pm';
require 'Level2ReportMerger.pm';
require 'Level3ReportMerger.pm';
require 'StatusReportMerger.pm';
use Log::Log4perl;
use Getopt::Std;

Log::Log4perl->init("configuration/log4perl.conf");
my $t0 = Benchmark->new;
my $conf = Configuration->instance;
my @report_generators = ();

our ($opt_f, $opt_t, $opt_i, $opt_o);

#Parse cmd params
getopts('f:t:i:o:');
$conf->log_dir($opt_i) if $opt_i;
$conf->output_dir($opt_o) if $opt_o;

my ($date_from, $date_to); 
defined $opt_f ? $date_from = Date->new($opt_f) : die "You must specify an starting date to generate the report (-f yyyy-mm-dd)";
defined $opt_t ? $date_to = Date->new($opt_t) : die "You must specify a finishing date to generate the report (-f yyyy-mm-dd)";

push (@report_generators, GlobalStatsReportGenerator->new);
#push (@parsers, HostsReportGenerator->new(config => $conf, writer => $writer, report_merger => $global_merger));
push (@report_generators, PaginasReportGenerator->new);
push (@report_generators, StatusReportGenerator->new);
push (@report_generators, CategoriasReportGenerator->new);
push (@report_generators, CategoriaUsuarioReportGenerator->new);
push (@report_generators, CategoriaUsuarioPaginaReportGenerator->new);
push (@report_generators, SearchReportGenerator->new);
push (@report_generators, UsuarioTraficoReportGenerator->new);
push (@report_generators, PaginaUsuariosReportGenerator->new);
push (@report_generators, DescargasReportGenerator->new);
push (@report_generators, NoCategorizadosReportGenerator->new);
# Browsers report
push (@report_generators, BrowserReportGenerator->new(field => 'c-agent'));

# Clientes unicos
push (@report_generators, SimpleReportGenerator->new(field => 'cs-username', file_name => 'clients.json'));

my $interval_merger = DaysIntervalMerger->new(reports => \@report_generators);
$interval_merger->merge_interval($date_from, $date_to);

my $tf = Benchmark->new;
my $td = timediff($tf, $t0);

my $log = Log::Log4perl->get_logger("main");

$log->info("Done.");
$log->info("Time elapsed: ", timestr($td));