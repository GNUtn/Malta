use warnings;
use strict;
use Benchmark;
use lib 'report-generator';
use lib 'common';
use lib 'configuration';
use lib 'writer';
use lib 'parser';
require 'Configuration.pm';
require 'Utils.pm';
require 'Parser.pm';
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
require 'GlobalMerger.pm';
require 'StatusGlobalMerger.pm';
use Log::Log4perl;

Log::Log4perl->init("configuration/log4perl.conf");
my $t0 = Benchmark->new;
my $conf = Configuration->new();
my $writer = ReportWriter->new($conf);
my $global_merger = GlobalMerger->new();
my @parsers = ();

push (@parsers, new GlobalStatsReportGenerator($conf, $writer, $global_merger));
#push (@parsers, new HostsReportGenerator($conf, $writer));
push (@parsers, new PaginasReportGenerator($conf, $writer, $global_merger));
push (@parsers, new StatusReportGenerator($conf, $writer, StatusGlobalMerger->new()));
push (@parsers, new CategoriasReportGenerator($conf, $writer, $global_merger));
push (@parsers, new CategoriaUsuarioReportGenerator($conf, $writer, $global_merger));
push (@parsers, new CategoriaUsuarioPaginaReportGenerator($conf, $writer, $global_merger));
push (@parsers, new SearchReportGenerator($conf, $writer, $global_merger));
push (@parsers, new UsuarioTraficoReportGenerator($conf, $writer, $global_merger));
push (@parsers, new PaginaUsuariosReportGenerator($conf, $writer, $global_merger));

my $parser = Parser->new( \@parsers, $conf);
my @files = map {$conf->log_dir.$_} @{Utils->get_files_list($conf->log_dir, $conf->file_patterns)};

$parser->parse_files(\@files);

my $tf = Benchmark->new;
my $td = timediff($tf, $t0);

my $log = Log::Log4perl->get_logger("main");

$log->info("Done.");
$log->info("Time elapsed: ", timestr($td));
