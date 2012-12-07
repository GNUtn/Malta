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
require 'DescargasReportGenerator.pm';
require 'ProtocolosReportGenerator.pm';
require 'SimpleReportGenerator.pm';
use Log::Log4perl;
use Getopt::Std;

Log::Log4perl->init("configuration/log4perl.conf");
my $t0 = Benchmark->new;
my $conf = Configuration->new();
my $writer = ReportWriter->new($conf);
my $global_merger = GlobalMerger->new();
my @parsers = ();
our $opt_f;
our $opt_w;

#Parse cmd params
getopts('w:f:');
$conf->web_file_patterns($opt_w) if $opt_w;
$conf->fws_file_patterns($opt_f) if $opt_f;

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
push (@parsers, new DescargasReportGenerator($conf, $writer, $global_merger));
# Browsers report
my $BrowsersReportGenerator = SimpleReportGenerator->new($conf, $writer, $global_merger);
$BrowsersReportGenerator->field('c-agent');
$BrowsersReportGenerator->file_name('browsers.json');
push (@parsers, $BrowsersReportGenerator);

my $parser = Parser->new( \@parsers, $conf);
my @files = map {$conf->log_dir.$_} @{Utils->get_files_list($conf->log_dir, $conf->web_file_patterns)};

$parser->parse_files(\@files);

$writer->write_version($conf->output_dir);


#PArse firewall files

@parsers = ();
push (@parsers, ProtocolosReportGenerator->new($conf, $writer, $global_merger));
@files = map {$conf->log_dir.$_} @{Utils->get_files_list($conf->log_dir, $conf->fws_file_patterns)};
$parser->parse_files(\@files);

my $tf = Benchmark->new;
my $td = timediff($tf, $t0);

my $log = Log::Log4perl->get_logger("main");

$log->info("Done.");
$log->info("Time elapsed: ", timestr($td));
