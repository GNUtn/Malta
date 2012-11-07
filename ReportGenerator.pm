package ReportGenerator;
use Mouse;
use Data::Dumper;
use URI;
require 'ReportWriter.pm';
require 'Dates.pm';

#Habrá una subclase de esta por cada reporte

has 'writer' => (
	is  => 'rw',
	isa => 'ReportWriter',
);

has 'data_hash' => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { my %hash = (); return \%hash }
);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

has 'global_stats' => (
	is  => 'rw',
	isa => 'GlobalStats',
);

has 'date_utils' => (
	is      => 'rw',
	isa     => 'Dates',
	default => sub { new Dates() }
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig(
		config       => $_[0],
		global_stats => $_[1],
		writer       => $_[2]
	);
};

sub write_report {
	my ( $self, $output_dir ) = @_;
	$self->writer->write( $self->data_hash, $output_dir, $self->get_file_name );
}

sub parse_values {
	my ( $self, $values ) = @_;

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se hacen cosas con los valores y se suman a hash_data
}

sub update_totals {
	my ($self) = @_;

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se calculan los porcentajes con los totales y todo eso
	return 1;
}

sub get_file_name {
	my ($self) = @_;

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Devolver el nombre del archivo a escribir para cada reporte
}

sub is_acceso {
	my ( $self, $values ) = @_;

	#TODO
	return 1;
}

sub parse_url {
	my ( $self, $url ) = @_;
	if ( $url !~ /.*\/\/.*/ ) {
		$url = "http://" . $url;
	}
	return URI->new($url);
}

#Agregar acá métodos comunes a todos como es_acceso(), get_fecha(), etc.
1;
