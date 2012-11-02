use warnings;
use strict;
require 'Configuration.pm';
require 'Utils.pm';
require 'Parser.pm';
require 'ReportGenerator.pm';

my $conf = new Configuration();
my @parsers = ();
push (@parsers, new ReportGenerator());
my $parser = new Parser( \@parsers, $conf);
my @files = map {$conf->log_dir.$_} @{Utils->get_files_list($conf->log_dir)};
$parser->parse_files(\@files);