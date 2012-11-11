package GlobalStatsReportGenerator;
use Mouse;
extends 'ReportGenerator';

sub BUILD {
	my $self = shift;
	$self->data_hash->{peticiones} = 0;
	$self->data_hash->{trafico}    = 0;
}

sub parse_values {
	my ( $self, $values ) = @_;
	$self->data_hash->{peticiones} += 1;
	$self->data_hash->{trafico}    += $self->get_trafico($values);
}

sub write_report {
	my ( $self, $output_dir ) = @_;
	$self->writer->write( $self->data_hash, $output_dir . 'internal/',
		$self->get_file_name );
	my @aaData = ( $self->data_hash );
	my %datatablesData = ( aaData => \@aaData );
	$self->writer->write( \%datatablesData, $output_dir . 'datatables/',
		$self->get_file_name );
}

sub get_file_name {
	return "global.json";
}
1;
