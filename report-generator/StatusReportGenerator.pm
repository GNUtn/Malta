package StatusReportGenerator;
use Mouse;
require 'DataHashFlatten.pm';
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $status = @$values[ $self->config->{fields}->{'sc-status'} ];
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $entry = $self->get_entry( $date, $self->get_category($status), $status );
	$entry->{ocurrencias} += 1;
}

sub get_file_name {
	return "status.json";
}

sub get_entry {
	my ( $self, $date, $categoria, $status ) = @_;

	if ( !exists $self->data_hash->{$date}->{$categoria}->{$status} ) {
		$self->data_hash->{$date}->{$categoria}->{$status} = $self->new_entry($status);
	}

	return $self->data_hash->{$date}->{$categoria}->{$status};
}

sub get_global_results {
	my ($self) = @_;
	foreach my $date ( keys %{ $self->data_hash } ) {
		foreach my $categoria ( keys %{ $self->data_hash->{$date} } ) {
			foreach my $status (keys %{$self->data_hash->{$date}->{$categoria}}){
				if ( exists $self->data_hash->{$categoria}->{$status} ) {
					$self->data_hash->{$categoria}->{$status}->{ocurrencias} +=
					  $self->data_hash->{$date}->{$categoria}->{ocurrencias};
				} else {
					$self->data_hash->{$categoria}->{$status} = $self->data_hash->{$date}->{$categoria}->{$status};
				}
				delete($self->data_hash->{$date}->{$categoria}->{$status});
			}
			delete($self->data_hash->{$date}->{$categoria});
		}
		delete($self->data_hash->{$date});
	}
	return $self->data_hash;
}

sub new_entry {
	my ( $self, $status ) = @_;
	my %entry = (
		descripcion => $self->details->{$status},
		ocurrencias => 0
	);
	return \%entry;
}

sub get_category {
	my ( $self, $status ) = @_;
	if ( $status >= 200 && $status < 300 ) {
		return "Success";
	}
	elsif ( $status >= 300 && $status < 400 ) {
		return "Redirect";
	}
	elsif ( $status >= 400 && $status < 500 ) {
		return "Client Error";
	}
	elsif ( $status >= 500 && $status < 600 ) {
		return "Server Error";
	}
	else {
		return "Other";
	}
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria status)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'ocurrencias';
}

has 'details' => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub {
		my %details = (
			100   => 'Continue',
			101   => 'Switching Protocols',
			200   => 'OK',
			201   => 'Created',
			202   => 'Accepted',
			203   => 'Non-Authoritative Information',
			204   => 'No Content',
			205   => 'Reset Content',
			206   => 'Partial Content',
			300   => 'Multiple Choices',
			301   => 'Moved Permanently',
			302   => 'Found',
			303   => 'See Other',
			304   => 'Not Modified',
			305   => 'Use Proxy',
			307   => 'Temporary Redirect',
			400   => 'Bad Request',
			401   => 'Unauthorized',
			402   => 'Payment Required',
			403   => 'Forbidden',
			404   => 'Not Found',
			405   => 'Method Not Allowed',
			406   => 'Not Acceptable',
			407   => 'Proxy Authentication Required',
			408   => 'Request Timeout',
			409   => 'Conflict',
			410   => 'Gone',
			411   => 'Length Required',
			412   => 'Precondition Failed',
			413   => 'Request Entity Too Large',
			414   => 'Request-URI Too Long',
			415   => 'Unsupported Media Type',
			416   => 'Requested Range Not Satisfiable',
			417   => 'Expectation Failed',
			418   => 'The HTCPCP server is a teapot',
			500   => 'Internal Server Error',
			501   => 'Not Implemented',
			502   => 'Bad Gateway',
			503   => 'Service Unavailable',
			504   => 'Gateway Timeout',
			505   => 'HTTP Version Not Supported',
			995   => 'Operation aborted.',
			10060 => 'A connection timed out.',
			10061 => 'A connection was refused by the destination host.',
			10065 => 'No route to host.',
			11001 => 'Host not found.',
			12201 =>
'A chained proxy server or array member requires proxy-to-proxy authentication. Please contact your server administrator.',
			12301 =>
'A chained server requires authentication. Contact the server administrator.',
			12202 =>
'The Forefront TMG denied the specified Uniform Resource Locator (URL).',
			12302 =>
'The server denied the specified Uniform Resource Locator (URL). Contact the server administrator.',
			12204 =>
'The specified Secure Sockets Layer (SSL) port is not allowed. Forefront TMG is not configured to allow SSL requests from this port. Most Web browsers use port 443 for SSL requests.',
			12304 =>
'The specified Secure Sockets Layer (SSL) port is not allowed. Forefront TMG is not configured to allow SSL requests from this port. Most Web browsers use port 443 for SSL requests.',
			12206 =>
'The Forefront TMG detected a proxy chain loop. There is a problem with the configuration of the Forefront TMG routing policy. Please contact your server administrator.',
			12306 =>
'The server detected a chain loop. There is a problem with the configuration of the server routing policy. Contact the server administrator.',
			12207 =>
'Forefront TMG dial-out connection failed. The administrator should manually dial the specified phonebook entry to determine if the number can be reached.',
			12307 =>
'The dial-out connection failed. The dial-out connection failed with the specified phonebook entry. The administrator should manually dial the specified phonebook entry to confirm that the problem is not the Windows auto-dial facility.',
			12208 =>
'Forefront TMG is too busy to handle this request. Reenter the request or renew the connection to the server (now or at a later time).',
			12308 =>
'The server is too busy to handle this request. Reenter the request or try again later.',
			12209 =>
'The Forefront TMG requires authorization to fulfill the request. Access to the Web Proxy filter is denied.',
			12309 =>
'The server requires authorization to fulfill the request. Access to the Web server is denied. Contact the server administrator.',
			12210 =>
'An Internet Server API (ISAPI) filter has finished handling the request. Contact your system administrator.',
			12310 =>
'An Internet Server API (ISAPI) filter has finished handling the request. Contact your system administrator.',
			12211 =>
'Forefront TMG requires a secure channel connection to fulfill the request. Forefront TMG is configured to respond to outgoing secure (Secure Sockets Layer (SSL)) channel requests.',
			12311 =>
'The page must be viewed over a secure channel (Secure Sockets Layer (SSL)). Contact the server administrator.',
			12213 =>
'Forefront TMG requires a client certificate to fulfill the request. A Secure Sockets Layer (SSL) Web server, during the authentication process, requires a client certificate.',
			12313 =>
'The page requires a client certificate as part of the authentication process. If you are using a smart card, you will need to insert your smart card to select an appropriate certificate. Otherwise, contact your server administrator.',
			12214 =>
'An Internet Server API (ISAPI) filter caused an error or terminated with an error.',
			12314 =>
'An Internet Server API (ISAPI) filter caused an error or terminated with an error.',
			12215 =>
'The size of the request header is too large. Contact your Forefront TMG administrator.',
			12315 =>
'The size of the request header is too large. Contact the server administrator.',
			12216 =>
'The size of the response header is too large. Contact your Forefront TMG administrator.',
			12316 =>
'The size of the response header is too large. Contact the server administrator.',
			12217 =>
'The request was rejected by the HTTP filter. Contact your Forefront TMG administrator.',
			12317 =>
'The request was rejected by the HTTP filter. Contact the server administrator.',
			12218 =>
'Forefront TMG cannot handle your request because the DNS quota was exceeded. Contact your Forefront TMG administrator.',
			12318 =>
'Forefront TMG cannot handle your request because the DNS quota was exceeded. Contact the server administrator.',
			12219 =>
'The number of HTTP requests per minute exceeded the configured limit. Contact your Forefront TMG administrator.',
			12319 =>
'The number of HTTP requests per minute exceeded the configured limit. Contact the server administrator.',
			12320 =>
'Forefront TMG is configured to block HTTP requests that require authentication.',
			12221 =>
'The client certificate used to establish the SSL connection with the Forefront TMG computer is not trusted.',
			12321 =>
'The client certificate used to establish the SSL connection with the Forefront TMG computer is not trusted.',
			12222 =>
'The client certificate used to establish the SSL connection with the Forefront TMG computer is not acceptable. The client certificate restrictions not met.',
			12322 =>
'The client certificate used to establish the SSL connection with the Forefront TMG computer is not acceptable. The client certificate restrictions not met.',
			12323 =>
'Authentication failed. The client certificate used to establish an SSL connection with the Forefront TMG computer does not match the user credentials that you entered.',
			12224 =>
'The SSL server certificate supplied by a destination server is not yet valid.',
			12225 =>
'The SSL server certificate supplied by a destination server expired.',
			12226 =>
'The certification authority that issued the SSL server certificate supplied by a destination server is not trusted by the local computer.',
			12227 =>
'The name on the SSL server certificate supplied by a destination server does not match the name of the host requested.',
			12228 =>
'The SSL certificate supplied by a destination server cannot be used to validate the server because it is not a server certificate.',
			12229 =>
'The Web site requires a client certificate, but a client certificate cannot be supplied when HTTPS inspection is applied to the request.',
			12230 =>
'The SSL server certificate supplied by a destination server has been revoked by the certification authority that issued it.',
			12234 => 'The traffic was blocked by IPS.',
			12334 => 'The traffic was blocked by IPS.',
			12235 =>
'Web traffic was blocked for a rule with URL filtering enabled because the URL filtering database is not available.',
			12236 =>
'Download failed because a third-party Web content filter does not support downloads that exceed 4GB.',
			12336 =>
'Download failed because a third-party Web content filter does not support downloads that exceed 4GB.',
			12337 =>
'Download failed because the Link Translation filter does not support downloads that exceed 4GB.',
			12238 =>
'Download failed because the Compression filter does not support downloads that exceed 4GB.',
			12338 =>
'Download failed because the Compression filter does not support downloads that exceed 4GB.',
			12239 =>
'Request failed because the size of the request body is too large.',
			12339 =>
'Request failed because the size of the request body is too large.',
		);
		return \%details;
	}
);
1;
