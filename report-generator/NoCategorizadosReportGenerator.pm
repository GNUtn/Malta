package NoCategorizadosReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub get_file_name {
	return "no_categorized.json";
}

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

sub get_entry {
	my ( $self, $date, $categoria ) = @_;

	if ( !exists $self->data_hash->{$date}->{$categoria} ) {
		$self->data_hash->{$date}->{$categoria} = $self->new_entry;
	}
	return $self->data_hash->{$date}->{$categoria};
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
	return [qw(categoria)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'ocurrencias';
}
1;