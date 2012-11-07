package GlobalStats;
use Mouse;

has 'peticiones' => (
	is => 'rw',
	isa => 'Int',
	default => 0
);

has 'accesos' => (
	is => 'rw',
	isa => 'Int',
	default => 0
);

has 'trafico' => (
	is => 'rw',
	isa => 'Int',
	default => 0
);
1;