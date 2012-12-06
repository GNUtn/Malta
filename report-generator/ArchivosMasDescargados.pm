package ArchivosMasDescargados;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $date  = @$values[ $self->config->{fields}->{'date'} ];
	my $uri   = $self->parse_url($self->get_url($values));
	eval {$uri->as_string};
	if (!$@) {
		if ($self->get_file_from_path($uri->as_string)){
			my $entry = $self->get_entry( $date, $uri->as_string );
			$entry->{descargas} += 1;
			$entry->{transferencia} += $self->get_trafico($values);
		}
	}
}

# Verifica si es un archivo
sub get_file_from_path{
	my $self = shift;
	my $url = shift;
	
	if ($url =~ /^.*\.exe|\.rar|\.zip|\.txt|\.pdf|\.fla|\.swf|\.cab|\.mp3|\.mp4|\.m4v.*$/m){
		return 1;
	}
	return 0;
}

sub get_file_name {
	return "archivosMasDescargados.json";
}

sub get_entry {
	my ( $self, $date, $archivo ) = @_;

	if ( !exists $self->data_hash->{$date}->{$archivo} ) {
		$self->data_hash->{$date}->{$archivo} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$archivo};
}

sub get_flatten_data {
	my ($self, $key) = @_;
	my @aaData = ();
	foreach my $archivo ( keys %{ $self->data_hash->{$key} } ) {
		my %entry;
		$entry{archivo} = $archivo;
		$entry{descargas} = $self->data_hash->{$key}->{$archivo}->{descargas};
		$entry{transferencia} = $self->data_hash->{$key}->{$archivo}->{transferencia};
		push @aaData, \%entry;
	}
	return @aaData;
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
