package GlobalStatsReportGenerator;
use Mouse;
extends 'ReportGenerator';

sub parse_values {
	my ( $self, $values ) = @_;
	$self->global_stats->peticiones( $self->global_stats->peticiones + 1 );
	$self->global_stats->accesos( $self->global_stats->accesos + 1 )
	  if $self->is_acceso($values);
	$self->global_stats->trafico( $self->global_stats->peticiones +
		  @$values[ $self->config->{fields}->{'cs-bytes'} ] );
}

sub write_report {
	my ( $self, $output_dir ) = @_;
	my %data = (
		'peticiones' => $self->global_stats->{peticiones},
		'accesos'    => $self->global_stats->{accesos},
		'trafico'    => $self->global_stats->{trafico}
	);
	$self->writer->write( \%data, $output_dir, $self->get_file_name );
}

sub update_totals {
}

sub get_file_name {
	return "global.json";
}
1;
