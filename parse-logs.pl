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

my $t0 = Benchmark->new;
my $conf = new Configuration();
my $writer = new ReportWriter($conf);
my @parsers = ();
push (@parsers, new GlobalStatsReportGenerator($conf, $writer));
#push (@parsers, new HostsReportGenerator($conf, $writer));
push (@parsers, new PaginasReportGenerator($conf, $writer));
push (@parsers, new StatusReportGenerator($conf, $writer));
push (@parsers, new CategoriasReportGenerator($conf, $writer));
push (@parsers, new CategoriaUsuarioReportGenerator($conf, $writer));
push (@parsers, new CategoriaUsuarioPaginaReportGenerator($conf, $writer));
push (@parsers, new SearchReportGenerator($conf, $writer));
push (@parsers, new UsuarioTraficoReportGenerator($conf, $writer));
push (@parsers, new PaginaUsuariosReportGenerator($conf, $writer));
my $parser = new Parser( \@parsers, $conf);
my @files = map {$conf->log_dir.$_} @{Utils->get_files_list($conf->log_dir, $conf->file_patterns)};
$parser->parse_files(\@files);
my $tf = Benchmark->new;
my $td = timediff($tf, $t0);
print "Done.\n";
print "Time elapsed: ", timestr($td), "\n";
