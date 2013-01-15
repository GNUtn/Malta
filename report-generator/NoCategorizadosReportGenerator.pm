package NoCategorizadosReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(categoria)]});
has '+sort_field' => (default => 'ocurrencias');
has '+file_name' => (default => 'no_categorized.json');

sub parse_values {
	my ( $self, $values ) = @_;

	my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
	if ($category eq 'Unknown'){
		my $uri = $self->parse_url($self->get_url($values));
		eval {$uri->host};
		if (!$@) {
			my $date = @$values[ $self->config->{fields}->{'date'} ];
			my $entry = $self->get_entry( $date, $uri->host );
			$entry->{ocurrencias} += 1;
			$entry->{trafico} += $self->get_trafico($values);
		}
	}
}

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, trafico => 0);
	return \%entry;
};
__PACKAGE__->meta->make_immutable;
1;