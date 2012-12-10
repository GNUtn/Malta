package DescargasReportGenerator;
use Mouse;
use MouseX::NativeTraits::ArrayRef;
extends 'ReportGenerator';
require 'Utils.pm';

has 'mime_types' => (
	traits     => ['Array'],
	is      => 'rw',
	isa     => 'ArrayRef',
	default => sub {
			["application/octet-stream", "text/html",
			"text/plain",               "application/zip",
			"-",                        "",
			"application/pdf",          "application/x-shockwave-flash",
			"video/mp3",                "video/mp4",
			"video/x-flv",              "video/x-m4v"]
	},
	handles    => {
		filter_mime_types => 'grep'
	}
);

sub parse_values {
	my ( $self, $values ) = @_;
	my $date = @$values[ $self->config->{fields}->{'date'} ];
	my $uri =
	  $self->parse_url( @$values[ $self->config->{fields}->{'cs-uri'} ] );
	eval { $uri->host; $uri->path };
	if ( !$@ ) {
		my @mime_type =
		  split( ';', @$values[ $self->config->{fields}->{'cs-mime-type'} ] );
		if (   $self->is_file( $uri->path )
			&& $self->filter_by_mime_type( shift(@mime_type) ) )
		{
			my $entry = $self->get_entry( $date, $uri->host . $uri->path );
			$entry->{descargas} += 1;
			$entry->{transferencia} += $self->get_trafico($values);
		}
	}
}

sub get_flattened_data {
        my ($self, $hash_ref) = @_;
        my @aaData = ();
        foreach my $file ( keys %$hash_ref ) {
                my %entry;
                $entry{archivo} = $file;
                $entry{transferencia} = $hash_ref->{$file}->{transferencia};
                $entry{descargas} = $hash_ref->{$file}->{descargas};
                push @aaData, \%entry;
        }
        return \@aaData;
}

sub filter_by_mime_type {
	my ( $self, $mime_type ) = @_;

	if ( defined($mime_type) ) {
		return $self->filter_mime_types(sub { $_ eq $mime_type });
	}
	return 1;
}

# Verifica si es un archivo
sub is_file {
	my ( $self, $url ) = @_;

	return $url =~
	  m/.*(\.exe|\.rar|\.zip|\.txt|\.pdf|\.swf|\.cab|\.mp3|\.mp4|\.m4v)$/;
}

sub get_file_name {
	return "descargas.json";
}

sub get_entry {
	my ( $self, $date, $archivo ) = @_;

	if ( !exists $self->data_hash->{$date}->{$archivo} ) {
		$self->data_hash->{$date}->{$archivo} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$archivo};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( descargas => 0, transferencia => 0 );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(archivo)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'descargas';
}

1;
