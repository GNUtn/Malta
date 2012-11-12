package PaginasReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $url   = @$values[ $self->config->{fields}->{'cs-uri'} ];
	my $uri   = $self->parse_url($url);
	my $entry = $self->get_entry( $uri->host, $uri->path );
	$entry->{ocurrencias} += 1;
	$entry->{trafico} += $self->get_trafico($values);
}

sub get_file_name {
	return "paginas.json";
}

sub get_entry {
	my ( $self, $destino, $pagina ) = @_;

	if ( !exists $self->data_hash->{$destino}->{$pagina} ) {
		$self->data_hash->{$destino}->{$pagina} = $self->new_entry;
	}

	return $self->data_hash->{$destino}->{$pagina};
}

sub write_report {
	my ( $self, $output_dir ) = @_;

	$self->writer->write( $self->data_hash, $output_dir . 'internal/',
		$self->get_file_name );

	my @aaData = ();
	foreach my $destino ( keys %{ $self->data_hash } ) {
		foreach my $path ( keys %{ $self->data_hash->{$destino} } ) {
			my %entry;
			$entry{destino} = $destino;
			$entry{pagina}  = $path;
			$entry{ocurrencias} =
			  $self->data_hash->{$destino}->{$path}->{ocurrencias};
			$entry{trafico} = $self->data_hash->{$destino}->{$path}->{trafico};
			push @aaData, \%entry;
		}
	}
	my %data = ( aaData => \@aaData );
	$self->writer->write( \%data, $output_dir . 'datatables/',
		$self->get_file_name );
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, trafico => 0 );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(destino pagina)];
}
1;
