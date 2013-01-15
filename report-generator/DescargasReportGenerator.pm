package DescargasReportGenerator;
use Moose;
extends 'AbstractLevel1ReportGenerator';

with 'ReportGenerator';

has '+fields' => (default => sub {[qw(archivo)]});
has '+sort_field' => (default => 'descargas');
has '+file_name' => (default => 'descargas.json');

has 'mime_types' => (
	traits  => ['Array'],
	is      => 'rw',
	isa     => 'ArrayRef',
	default => sub {
		[
			"application/octet-stream", "text/html",
			"text/plain",               "application/zip",
			"-",                        "",
			"application/pdf",          "application/x-shockwave-flash",
			"video/mp3",                "video/mp4",
			"video/x-flv",              "video/x-m4v"
		];
	},
	handles => { filter_mime_types => 'grep' }
);

sub parse_values {
	my ( $self, $values ) = @_;
	my $uri =
	  $self->parse_url( @$values[ $self->config->{fields}->{'cs-uri'} ] );
	eval { $uri->host; $uri->path };
	if ( !$@ ) {
		my @mime_type =
		  split( ';', @$values[ $self->config->{fields}->{'cs-mime-type'} ] );
		if (   $self->is_file( $uri->path )
			&& $self->filter_by_mime_type( shift(@mime_type) ) )
		{
			my $date = @$values[ $self->config->{fields}->{'date'} ];
			my $entry = $self->get_entry( $date, $uri->host . $uri->path );
			$entry->{descargas} += 1;
			$entry->{transferencia} += $self->get_trafico($values);
		}
	}
}

override 'new_entry' => sub {
	my ($self) = @_;
	my %entry = ( descargas => 0, transferencia => 0 );
	return \%entry;
};

sub filter_by_mime_type {
	my ( $self, $mime_type ) = @_;

	if ( defined($mime_type) ) {
		return $self->filter_mime_types( sub { $_ eq $mime_type } );
	}
	return 1;
}

# Verifica si es un archivo
sub is_file {
	my ( $self, $url ) = @_;

	return $url =~
	  m/.*(\.exe|\.rar|\.zip|\.txt|\.pdf|\.swf|\.cab|\.mp3|\.mp4|\.m4v)$/;
}
__PACKAGE__->meta->make_immutable;
1;
