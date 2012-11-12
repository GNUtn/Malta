package Parser;
use Mouse;
use Data::Dumper;
require 'Utils.pm';
require 'Configuration.pm';

has 'report_generators' => (
	is  => 'rw',
	isa => 'ArrayRef'
);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig(
		report_generators => $_[0],
		config            => $_[1]
	);
};

sub parse_files {
	my ( $self, $file_paths ) = @_;

	foreach my $file_path ( @{$file_paths} ) {
		$self->parse_file($file_path);
	}

	foreach my $report_generator ( @{ $self->report_generators } ) {
		$report_generator->post_process();
		$report_generator->write_report( $self->config->output_dir );
	}
}

sub parse_file {
	my ( $self, $file_path ) = @_;
	open( INPUT, "<$file_path" ) or die $!, $file_path;

	while (<INPUT>) {
		my $line = Utils->rstrip($_);
		next if $self->is_excluded_line($line) || !$self->is_valid_line($line);

		my @values = split( $self->config->field_sep, $line );

		$self->pre_process_values( \@values );

		foreach my $report_generator ( @{ $self->report_generators } ) {
			$report_generator->parse_values( \@values );
		}
	}
}

sub is_excluded_line {
	my ( $self, $line ) = @_;
	foreach my $pattern ( @{ $self->config->exclude_patterns } ) {
		if ( $line =~ m/$pattern/ ) { return 1 }
	}
	return 0;
}

sub is_valid_line {
	my ( $self, $line ) = @_;
	my $pattern = $self->config->valid_line_pattern;
	return $line =~ m/$pattern/;
}

sub pre_process_values {
	my ( $self, $values ) = @_;
	@$values[ $self->config->{fields}->{'date'} ] = Date->new(@$values[ $self->config->{fields}->{'date'} ]);
}
1;
