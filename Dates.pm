package Dates;
use Mouse;
use DateTime;
use v5.10.1;

has 'valid_date_formats' => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub {
		my %valid_date_formats = (
			'AAAA/MM/DD' =>
'(?<year>(19|20)\d\d)([/\.-])?(?<month>0[1-9]|1[012])([/\.-])?(?<day>0[1-9]|[12][0-9]|3[01])',
			'DD/MM/AAAA' =>
'(?<day>0[1-9]|[12][0-9]|3[01])([/\.-])?(?<month>0[1-9]|1[012])([/\.-])?(?<year>(19|20)\d\d)',
			'MM/DD/AAAA' =>
'(?<month>0[1-9]|1[012])([/\.-])?(?<day>0[1-9]|[12][0-9]|3[01])([/\.-])?(?<year>(19|20)\d\d)',
			'DD/MMM/AAAA' =>
'(?<day>0[1-9]|[12][0-9]|3[01])([/\s\.-])(?<month>Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)([/\s\.-])(?<year>(19|20)\d\d)'
		);
		return \%valid_date_formats;
	}
);

has 'mont_equiv' => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub {
		my %month_equiv = (
			'Jan', '01', 'Feb', '02', 'Mar', '03', 'Apr', '04',
			'May', '05', 'Jun', '06', 'Jul', '07', 'Aug', '08',
			'Sep', '09', 'Oct', '10', 'Nov', '11', 'Dec', '12'
		);
		return \%month_equiv;
	}
);

has 'date_output_formats' => (
	is      => 'ro',
	isa     => 'HashRef',
	default => sub {
		my %date_output_formats = (
			'AAAA/MM/DD'  => '%Y%m%d',
			'DD/MM/AAAA'  => '%d%m%Y',
			'MM/DD/AAAA'  => '%m%d%Y',
			'DD/MMM/AAAA' => '%d%b%Y',
		);
		return \%date_output_formats;

	}
);

=head2 compareStr(date1, date2, "DD/MM/AAAA")
	Class method.
	Compara dos string con fechas en el formato $format.
	Como la función sort() de perl, devuelve:
	-1 si $dt1 < $dt2, 0 si $dt1 == $dt2, 1 si $dt1 > $dt2.
	El parámetro format es el formato en el que están las fechas.
	
	Ejemplos de uso:
		Dates->compare("30/01/2000", "31/01/2000", "DD/MM/AAAA")
		Dates->compare("08/30/2000", "08/31/2000", "MM/DD/AAAA")
		Dates->compare("30/Aug/2000", "31/Aug/2000", "DD/MMM/AAAA")
		Dates->compare("2000-01-30", "2000-01-31", "AAAA/MM/DD")
=cut

sub compare_str {
	my ( $self, $date1, $date2, $format ) = @_;
	return DateTime->compare(
		$self->parse_date( $date1, $format ),
		$self->parse_date( $date2, $format )
	);
}

=head2 compare(date1, date2)
	Class method.
	Compara dos objetos DateTime
	Como la función sort() de perl, devuelve:
	-1 si $dt1 < $dt2, 0 si $dt1 == $dt2, 1 si $dt1 > $dt2.
=cut

sub compare {
	my ( $self, $date1, $date2 ) = @_;
	return DateTime->compare( $date1, $date2 );
}

=head2 parseDate("01/01/2000", "DD/MM/AAAA")
	Class Method.
	Parsea un string fecha de acuerdo con el parámetro format y devuelve
	un objeto DateTime. Lo separadores de la fecha pueden ser "/", ".", "espacio" y "-"
	pero el formato siempre se indica con "/" independientemente del separador.
	
	Ejemplos de uso:
		Dates->parseDate("30/01/2000", "DD/MM/AAAA")
		Dates->parseDate("08/30/2000", "MM/DD/AAAA")
		Dates->parseDate("30/Aug/2000", "DD/MMM/AAAA")
		Dates->parseDate("2000-01-30", "AAAA/MM/DD")
=cut

sub parse_date {
	my ( $self, $date, $format ) = @_;
	my ( $year, $month, $day );
	my %valid_date_formats = %{$self->valid_date_formats};
	if ( grep $_ eq $format, keys %valid_date_formats ) {
		if ( $date =~ m/$valid_date_formats{$format}/ ) {
			$year  = $+{year};
			$month = $+{month};
			$day   = $+{day};
			if ( $month !~ /\d\d/ ) {
				$month = $self->month_equiv->{$month};
			}
			return DateTime->new(
				year  => $year,
				month => $month,
				day   => $day,
			);
		}
		else {
			throw Error::Simple "Invalid Date $date";
		}
	}
	else {
		throw Error::Simple "Invalid Date Format $format";
	}
}

sub is_valid_date {
	my ( $self, $date, $format ) = @_;
	my %valid_date_formats = %$self->valid_date_formats;
	if ( grep $_ eq $format, keys %valid_date_formats ) {
		return $date =~ m/$valid_date_formats{$format}/;
	}
}

sub toString {
	my ( $self, $date, $format, $sep ) = @_;
	my $strf = $self->date_output_formats->{$format};
	$strf =~ s/(\w+)%/$1$sep%/g;
	return $date->strftime($strf);
}

sub today {
	return DateTime->today;
}

sub oldest_date {
	return DateTime->new(
		year  => 0,
		month => 1,
		day   => 1,
	);
}
1;
