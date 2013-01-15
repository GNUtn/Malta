package AbstractLevel2ReportGenerator;
use Moose;
extends 'AbstractReportGenerator';

has '+report_merger' => (default => sub {Level2ReportMerger->instance} );

sub get_entry {
	my ( $self, $date, $key1, $key2 ) = @_;

	if ( !exists $self->data_hash->{$date}->{$key1}->{$key2} ) {
		$self->data_hash->{$date}->{$key1}->{$key2} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$key1}->{$key2};
}

sub get_flattened_data {
	my ( $self, $hash_ref ) = @_;
	my @aaData = ();
	while ( my ( $key1, $vals1 ) = each %$hash_ref ) {
		while ( my ( $key2, $vals2 ) = each %$vals1 ) {
			my %entry;
			$entry{$self->get_fields->[0]} = $key1;
			$entry{$self->get_fields->[1]} = $key2;
			while ( my ( $key3, $vals3 ) = each %$vals2 ) {
				$entry{$key3} = $vals3;
			}
			push @aaData, \%entry;
		}
	}
	my $aaData = { aaData => \@aaData };
	return $aaData;
}

sub get_lowest {
	my ( $self, $hash ) = @_;
	my @vals = ();
	while ( my ( $key1, $vals1 ) = each %$hash ) {
		while ( my ( $key2, $vals2 ) = each %$vals1 ) {
			push @vals, $vals2->{$self->get_sort_field};
		}
	}
	if ( scalar @vals > $self->config->globals_limit ) {
		@vals = sort(@vals[ 0 .. $self->config->globals_limit ]);
		return $vals[-1];
	} else {
		return undef;
	}
}

sub trim_hash {
	my ($self, $hash_ref, $lowest_val) = @_;
	while ( my ( $key1, $vals1 ) = each %$hash_ref ) {
		while ( my ( $key2, $vals2 ) = each %$vals1 ) {
			while ( my ( $key3, $val3 ) = each %$vals2 ) {
				if($key3 eq $self->get_sort_field && $val3 <= $lowest_val) {
					delete $hash_ref->{$key1}->{$key2};
				}
			}
		}
		delete $hash_ref->{$key1} if (scalar keys %$vals1 <= 0);
	}
}
__PACKAGE__->meta->make_immutable;
1;
