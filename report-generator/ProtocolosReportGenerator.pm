package ProtocolosReportGenerator;
use Mouse;
extends 'ReportGenerator';

sub parse_values {
	my ( $self, $values ) = @_;
	my $trafico = $self->get_trafico($values);
	
	if ($trafico > 0) {
		my $uri = $self->parse_url(@$values[ $self->config->{firewall_fields}->{'destination'} ]);
		eval {$uri->port};
		
		if (!$@) {
			my $date = @$values[ $self->config->{firewall_fields}->{'date'} ];
			my $protocol = @$values[ $self->config->{firewall_fields}->{'application protocol'} ];
			my $entry    = $self->get_entry( $date, $uri->port, $protocol );
			$entry->{trafico} += $trafico;
		}
	}
}

#Override
sub get_trafico {
	my ( $self, $values ) = @_;
	return ( @$values[ $self->config->{firewall_fields}->{'bytes sent'} ] +
		  @$values[ $self->config->{firewall_fields}->{'bytes received'} ] );
}

sub get_file_name {
	return "protocolos.json";
}

sub get_entry {
	my ( $self, $date, $port, $protocol ) = @_;

	if ( !exists $self->data_hash->{$date}->{$port}->{$protocol} ) {
		$self->data_hash->{$date}->{$port}->{$protocol} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$port}->{$protocol};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( trafico => 0, );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(puerto protocolo)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'trafico';
}
1;
