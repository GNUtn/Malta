package AbstractReportGenerator;
use Moose;
use URI;
require 'ReportWriter.pm';
require 'Date.pm';

has 'writer' => (
	is  => 'rw',
	isa => 'ReportWriter',
	default => sub {ReportWriter->instance},
);

has 'data_hash' => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub { my %hash = (); return \%hash },
);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
	default => sub {Configuration->instance},
);

has 'report_merger' => (
	is  => 'rw',
);

has 'fields' => (
	is  => 'rw',
	isa => 'ArrayRef',
	reader => 'get_fields',
);

has 'sort_field' => (
	is  => 'rw',
	isa => 'Str',
	reader => 'get_sort_field',
);

has 'file_name' => (
	is  => 'rw',
	isa => 'Str',
	reader => 'get_file_name',
);

sub new_entry {
	#Reports having fields other than "ocurrencias" must override this method
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, );
	return \%entry;
}

sub post_process {
	#By default does nothing. Override if necessary.
}

sub write_report {
	my ( $self, $output_dir ) = @_;
	
	my $logger = Log::Log4perl->get_logger("ReportGenerator");
	while (my($date, $vals) = each %{$self->{data_hash}}) {
		my $date_output_dir = Date->new($date)->to_string('/') . "/";
		
		$logger->debug("Flattening data", $self->get_file_name);
		my $aaData = $self->get_flattened_data($vals);

		$logger->debug("Writing data");
		$self->writer->write_top( $aaData, $self->get_sort_field, $output_dir . 'datatables/' . $date_output_dir, $self->get_file_name );
		Hashes->store_hash($vals, $output_dir . 'internal/' . $date_output_dir, $self->get_file_name);
	}
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

#Agregar acá métodos comunes a todos como es_acceso(), get_fecha(), etc.
__PACKAGE__->meta->make_immutable;
1;
