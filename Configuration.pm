package Configuration;
use Mouse;

has 'log_dir' => (
	is => 'rw',
	isa => 'Str',
	default => '/home/sergioo/logs/1/'
);

has 'output_dir' => (
	is => 'rw',
	isa => 'Str',
	default => 'output/'
);

has 'debug' => (
	is => 'rw',
	isa => 'Bool',
	default => ''
);

has 'field_sep' => (
	is      => 'rw',
	isa     => 'Str',
	default => '\t'
);

has 'date_format' => (
	is      => 'rw',
	isa     => 'Str',
	default => '%Y-%m-%d'
);

has 'time_format' => (
	is      => 'rw',
	isa     => 'Str',
	default => '%H:%M:%S'
);

has 'fields' => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { my %hash = (
			'c-ip' => 0,
			'cs-username' => 1,
			'c-agent' => 2,
			'sc-authenticated' => 3,
			'date' => 4,
			'time' => 5,
			's-svcname' => 6,
			's-computername' => 7,
			'cs-referred' => 8,
			'r-host' => 9,
			'r-ip' => 10,
			'r-port' => 11,
			'time-taken' => 12,
			'sc-bytes' => 13,
			'cs-bytes' => 14,
			'cs-protocol' => 15,
			's-operation' => 16,
			'cs-uri' => 17,
			'cs-mime-type' => 18,
			'sc-status' => 19,
			'rule' => 20,
			'FilterInfo' => 21,
			'cs-network' => 22,
			'sc-network' => 23,
			'error-info' => 24,
			'action' => 25,
			'GMT Time' => 26,
			'AuthenticationServer' => 27,
			'ThreatName' => 28,
			'UrlCategory' => 29,
			'MalwareInspectionContentDeliveryMethod' => 30,
			'UrlCategorizationReason' => 31,
			'SessionType' => 32,
			'UrlDestHost' => 33
		); return \%hash;});
1;