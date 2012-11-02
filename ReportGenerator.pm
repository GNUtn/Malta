package ReportGenerator;
use Mouse;
require 'ReportWriter.pm';

#Habrá una subclase de esta por cada reporte

has 'writer' => (
	is  => 'rw',
	isa => 'ReportWriter',
	default => sub {return new ReportWriter()}
);

has 'data_hash' => (
	is => 'rw',
	isa => 'HashRef'
);

sub parse_values {
	my ($self, $values) = @_;
	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se hacen cosas con los valores y se suman a hash_data
}

sub update_totals {
	my ($self) = @_;
	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se calculan los porcentajes con los totales y todo eso
	return 1;
}

sub write_report {
	my ( $self, $output_dir ) = @_;
	$self->writer->write($self->data_hash, $output_dir);
}

#Agregar acá métodos comunes a todos como es_acceso(), get_fecha(), etc.
1;