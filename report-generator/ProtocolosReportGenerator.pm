package ProtocolosReportGenerator;
use Moose;
extends 'AbstractLevel2ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(puerto protocolo)]});
has '+sort_field' => (default => 'trafico');
has '+file_name' => (default => 'protocolos.json');

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

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = ( trafico => 0, );
	return \%entry;
};

override 'get_trafico' => sub {
	my ( $self, $values ) = @_;
	return ( @$values[ $self->config->{firewall_fields}->{'bytes sent'} ] +
		  @$values[ $self->config->{firewall_fields}->{'bytes received'} ] );
};
__PACKAGE__->meta->make_immutable;
1;
