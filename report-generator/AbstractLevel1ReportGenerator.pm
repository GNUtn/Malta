package AbstractLevel1ReportGenerator;
use Moose;
extends 'AbstractReportGenerator';

has '+report_merger' => (default => sub {Level1ReportMerger->instance});

sub get_entry {
	my ( $self, $date, $key ) = @_;

	if ( !exists $self->data_hash->{$date}->{$key} ) {
		$self->data_hash->{$date}->{$key} = $self->new_entry;
	}
	return $self->data_hash->{$date}->{$key};
}

sub get_flattened_data {
	my ( $self, $hash_ref ) = @_;
	my @aaData = ();
	while ( my ( $key, $vals ) = each %$hash_ref ) {
		my %entry;
		$entry{$self->get_fields->[0]} = $key;
		while ( my ( $key2, $val2 ) = each %$vals ) {
			$entry{$key2} = $val2;
		}
		push @aaData, \%entry;
	}
	my $aaData = { aaData => \@aaData };
	return $aaData;
}

sub get_lowest {
	my ( $self, $hash ) = @_;
	my @vals = map { $hash->{$_}->{ $self->get_sort_field } } keys %$hash;
	if ( scalar @vals > $self->config->globals_limit ) {
		@vals = sort(@vals[ 0 .. $self->config->globals_limit ]);
		return $vals[-1];
	} else {
		return undef;
	}
}

sub trim_hash {
	my ($self, $hash_ref, $lowest_val) = @_;
	while ( my ( $key, $vals ) = each %$hash_ref ) {
		while ( my ( $key2, $val2 ) = each %$vals ) {
			if($key2 eq $self->get_sort_field && $val2 <= $lowest_val) {
				delete $hash_ref->{$key};
			}
		}
	}
}
__PACKAGE__->meta->make_immutable;
1;
