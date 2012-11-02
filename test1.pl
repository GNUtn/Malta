#!/usr/bin/perl
use strict;
use warnings;

use Config::Simple;

print "Begin\n";

require "Log.pm";

my $cfg = new Config::Simple('app.cfg');
my @array_structure = split(' ', $cfg->param("Logs.structure"));
my $log = Log->new(
	$cfg->param("Logs.path") . $cfg->param("Logs.fileName"),
	$cfg->param("Logs.skipLines"),
	\@array_structure,
	$cfg->param("Application.granularity")
);
$log->open_log();

$log->separator($cfg->param("Logs.separator"));

$log->process();

#print "Lines: " . $log->lines_count() . ".\n";

$log->close();

undef $log;

print "The end";
