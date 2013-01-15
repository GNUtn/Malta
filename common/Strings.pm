package Strings;
use Moose;

sub rstrip {
	my ( $class, $line ) = @_;
	chop($line);
	$line =~ s/\s+$//;
	return $line;
}
__PACKAGE__->meta->make_immutable;
1;
