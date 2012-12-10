package SearchReportGenerator;
use Mouse;
use URI::QueryParam;
use Data::Dumper;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	#Por ahora, sólo busca para google, yahoo, bing y algún otro que
	#tenga /search?q= en la url
	my ( $self, $values ) = @_;

	my $url = @$values[ $self->config->{fields}->{'cs-uri'} ];
	my $uri = $self->parse_url($url);

	if ( $uri->path =~ m/search/ ) {
		my $query;
		if ( $uri->query_param('oq') ) {
			$query = $uri->query_param('oq');
		}
		elsif ( $uri->query_param('q') ) {
			$query = $uri->query_param('q');
		}
		elsif ( $uri->query_param('p') ) {
			$query = $uri->query_param('p');
		}
		if ( $query && length($query ) > $self->config->search_length ) {
			my $date  = @$values[ $self->config->{fields}->{'date'} ];
			my $entry = $self->get_entry( $date, lc $query );
			$entry->{ocurrencias} += 1;
		}
	}
}

sub get_flattened_data {
        my ($self, $hash_ref) = @_;
        my @aaData = ();
        foreach my $query ( keys %$hash_ref ) {
                my %entry;
                $entry{ocurrencias} = $hash_ref->{$query}->{ocurrencias};
                $entry{query} = $query;
                push @aaData, \%entry;
        }
        return \@aaData;
}

sub get_file_name {
	return "searchs.json";
}

sub get_entry {
	my ( $self, $date, $query ) = @_;

	if ( !exists $self->data_hash->{$date}->{$query} ) {
		$self->data_hash->{$date}->{$query} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$query};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(query)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'ocurrencias';
}
1;
