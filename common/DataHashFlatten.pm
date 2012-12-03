package DataHashFlatten;

require 5.005_62;
use strict;
use warnings;

our @flattened=();

sub flatten {
	my ( $class, $level, $href, $field, $depth, $flat_rec ) = @_;
	@flattened=() unless defined($depth);
	$depth     = 0  unless defined($depth);
	my @key = keys %$href;

	if ( $level > $depth ) {
		for my $key_i ( 0 .. $#key ) {
			my $key = $key[$key_i];
			$flat_rec->{ $field->[$depth] } = $key;

			$class->flatten(
				$level,     $href->{$key}, $field,
				$depth + 1, $flat_rec,     @flattened
			);
		}
	}
	else {
		for my $key (@key) {
			$flat_rec->{$key} = ${$href}{$key};
		}
		my %new_rec = %{$flat_rec};
		push @flattened, \%new_rec;
	}

	\@flattened;
}

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

DataHashFlatten - isomorphic denormalization of nested HoH into AoH

=head1 SYNOPSIS

  use DataHashFlatten;

  my $a = { bill => { '5/27/96' => { 'a.dat' => 1, 'b.txt' => 2, 'c.lsp' => 3 } },
            jimm => { '6/22/98' => { 'x.prl' => 9, 'y.pyt' => 8, 'z.tcl' => 7 } } } ;


  my @a = DataHashFlatten->flatten(2, $a, [qw(name date)]);
  
  use Data::Dumper;
  print Dumper(\@a);

  $VAR1 = [
          {
            'date' => '6/22/98',
            'name' => 'jimm',
            'z.tcl' => 7
          },
          {
            'date' => '6/22/98',
            'name' => 'jimm',
            'y.pyt' => 8
          },
          {
            'date' => '6/22/98',
            'name' => 'jimm',
            'x.prl' => 9
          },
          {
            'date' => '5/27/96',
            'name' => 'bill',
            'c.lsp' => 3
          },
          {
            'date' => '5/27/96',
            'name' => 'bill',
            'b.txt' => 2
          },
          {
            'date' => '5/27/96',
            'name' => 'bill',
            'a.dat' => 1
          }
        ];



=head1 DESCRIPTION

Oftentimes, for searchability, one needs to denormalize a HoH (hash of hash of hash of ...) into an
AoH (array of hash). The answer by C<George_Sherston> in this node gives an perfect example of how 
and why: 

  http://perlmonks.org/index.pl?node_id=177346

Hence this module.


=head2 EXPORT

None by default.


=head1 AUTHOR

Sergio Orbe, based in Data::Hash::Flatten from T. M. Brannon, <tbone@cpan.org>

=head1 SEE ALSO

  "Data Munging with Perl" by Dave Cross

=cut
