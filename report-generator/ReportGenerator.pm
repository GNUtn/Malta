package ReportGenerator;
use Mouse;
use URI;
require 'ReportWriter.pm';
require 'DataHashFlatten.pm';
require 'Date.pm';

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

has 'report_merger' => (
	is  => 'rw',
	isa => 'ReportMerger',
);

sub write_report {
	my ( $self, $output_dir ) = @_;
	
	my $logger = Log::Log4perl->get_logger("ReportGenerator");
	foreach my $date ( keys %{$self->{data_hash}} ) {

		my $date_output_dir = Date->new($date)->to_string('/') . "/";
		
		$logger->debug("Flattening data");
		my $aaData = $self->get_flattened_data($self->{data_hash}->{$date});

		$logger->debug("Writing data");
		$self->writer->write_top( $aaData, $self->get_sort_field, $output_dir . 'datatables/' . $date_output_dir, $self->get_file_name );
		Hashes->store_hash($self->{data_hash}->{$date}, $output_dir . 'internal/' . $date_output_dir, $self->get_file_name);
	}
}

sub get_flattened_data {
	my ($self, $hash_ref) = @_;
	my @aaData = DataHashFlatten->flatten( $self->get_level(), $hash_ref, $self->get_fields() );
	my %data = ( aaData => \@aaData );
	return \%data;
}

sub parse_url {
	my ( $self, $url ) = @_;
	if ( $url !~ /.*\/\/.*/ ) {
		$url = "http://" . $url;
	}
	return URI->new($url);
}

sub get_url {
	my ($self, $values) = @_;
	my $url   = @$values[ $self->config->{fields}->{'cs-referred'} ];
	if ($url eq '-') {
		$url   = @$values[ $self->config->{fields}->{'cs-uri'} ];
	}
	return $url;
}

sub get_trafico {
	my ( $self, $values ) = @_;
	return ( @$values[ $self->config->{fields}->{'cs-bytes'} ] +
		  @$values[ $self->config->{fields}->{'sc-bytes'} ] );
}

sub parse_values {

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se hacen cosas con los valores y se suman a hash_data
}

sub post_process {

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Acá se calculan los porcentajes con los totales y todo eso
}

sub get_file_name {

	# TO BE IMPLEMENTED BY SUBCLASSES
	#Devolver el nombre del archivo a escribir para cada reporte
}

#Agregar acá métodos comunes a todos como es_acceso(), get_fecha(), etc.
1;
