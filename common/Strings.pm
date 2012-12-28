package Strings;
use Mouse;

sub rstrip {
	my ( $class, $line ) = @_;
	chop($line);
	$line =~ s/\s+$//;
	return $line;
}
1;
