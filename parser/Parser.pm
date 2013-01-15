package Parser;
use Moose;
use List::MoreUtils qw(any);

has 'report_generators' => (
	is  => 'rw',
	isa => 'ArrayRef',
	required => 1
);

has 'config' => (
	is  => 'rw',
	isa => 'Configuration',
	default => sub {Configuration->instance},
);

sub parse_files {
	my ( $self, $file_paths, $dates_to_parse ) = @_;
	my $size = scalar(keys %{$self->config->{fields}});
	$self->config->{fields}->{'parsed-date'} = $size;

	foreach my $file_path ( @{$file_paths} ) {
		$self->parse_file($file_path, $dates_to_parse);
	}

	foreach my $report_generator ( @{ $self->report_generators } ) {
		$report_generator->post_process();
		$report_generator->write_report( $self->config->output_dir );
	}
}

sub parse_file {
	my ( $self, $file_path, $dates_to_parse ) = @_;
	my $log = Log::Log4perl->get_logger("Parser");
	
	open( INPUT, "<$file_path" ) or $log->logdie($!, $file_path);
	
	$log->info("Computing data from file: ", $file_path, "...");

	while (<INPUT>) {
		my $line = Strings->rstrip($_);
		next if $self->is_excluded_line($line) || !$self->is_valid_line($line);

		my @values = split( $self->config->field_sep, $line );
		
		$self->pre_process_values( \@values );
		next if !$self->is_valid_date(\@values, $dates_to_parse);

		foreach my $report_generator ( @{ $self->report_generators } ) {
			$report_generator->parse_values( \@values );
		}
	}
	close INPUT;
}

sub is_valid_date {
	my ($self, $values, $dates_to_parse) = @_;
	return any {$_->compare_to(@$values[ $self->config->{fields}->{'parsed-date'} ]) == 0} @$dates_to_parse;
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
	@$values[ $self->config->{fields}->{'parsed-date'} ] = Date->new(@$values[ $self->config->{fields}->{'date'} ]);
}
__PACKAGE__->meta->make_immutable;
1;
