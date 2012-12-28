package Date;
use Mouse;
use Date::Calc qw( Delta_Days Add_Delta_Days );

has 'day' => (
	is  => 'rw',
	isa => 'Int'
);

has 'month' => (
	is  => 'rw',
	isa => 'Int'
);

has 'year' => (
	is  => 'rw',
	isa => 'Int'
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	my $pattern = '(?<anio>(19|20)\d\d)([/\.-])?(?<mes>0[1-9]|1[012])([/\.-])?(?<dia>0[1-9]|[12][0-9]|3[01])';
	
	if ( defined($_[2]) ) {
		return $class->$orig(
			year  => $_[0],
			month => $_[1],
			day   => $_[2]
		);
		
	} elsif ( defined($_[0]) && $_[0] =~ m/$pattern/ ) {

		return $class->$orig(
			year  => $+{anio},
			month => $+{mes},
			day   => $+{dia}
		);
	} else {
		return $class->$orig(
			year  => 1970,
			month => 1,
			day   => 1
		);
	}
};

sub compare_to {
	my ( $self, $other_date ) = @_;
	return Delta_Days( $self->year, $self->month, $self->day, $other_date->year,
		$other_date->month, $other_date->day );
}

sub get_new_plus_days {
	my ($self, $offset) = @_;
	my ($year, $month, $day) = Add_Delta_Days($self->year, $self->month, $self->day, $offset);
	return Date->new($year, $month, $day);
}

sub to_string {
	my ( $self, $sep ) = @_;
	return sprintf("%d%s%02d%s%02d", $self->year, $sep, $self->month, $sep, $self->day);
}
1;
