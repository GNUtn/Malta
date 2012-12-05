#!/usr/bin/perl

package Counter;
use Mouse;

has 'name' =>(
	is      => 'ro',
	isa     => 'Str'
);

has 'field_index' =>(
	is      => 'ro',
	isa     => 'Int'
);

has 'total_count' =>(
	is      => 'ro',
	isa     => 'Int',
	writer	=> '_set_total_count',
	default => 0
);

has 'counters' =>( 
	is      => 'ro',
	isa     => 'HashRef', # value->count
	default => sub { my %hash; return \%hash; }
);

has 'preprocess' =>(
	is      => 'ro',
	isa     => 'ArrayRef' # Array de regex
);

has 'exclude' =>(
	is      => 'ro',
	isa     => 'HashRef' # index->regex match condition
);

has 'summarizers' =>(
	is      => 'ro',
	isa     => 'ArrayRef' # fields list
);

has 'summarizers_sums' =>(
	is      => 'ro',
	isa     => 'HashRef', # value->sum
	default => sub { my %hash; return \%hash; }
);

has 'other_counters' =>(
	is      => 'ro',
	isa     => 'HashRef' # index->regex match condition
);

has 'other_counters_counts' =>(
	is      => 'ro',
	isa     => 'HashRef', # value->count
	default => sub { my %hash; return \%hash; }
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig(
		name    		=> $_[0],
		field_index		=> $_[1],
		preprocess   	=> $_[2],
		exclude			=> $_[3],
		summarizers		=> $_[4],
		other_counters	=> $_[5]
	);
};

sub BUILD {
	my $self = shift;

	return 1;
}

sub _preprocess_field {
	my $self  = shift;
	my $value = shift;

	foreach my $regex ( @{$self->preprocess} ) {
		my $code = "";
		$code = '$value =~ ' . $regex . ';';
		eval($code);
	}
	return $value;
}

sub _exclude_line {
	my $self  = shift;
	my @line_splited = @{ $_[0] };
	
	foreach my $field_exclude ( keys  %{$self->exclude}) {
		my $cond = $self->exclude->{$field_exclude};
		if($line_splited[$field_exclude] =~ m/$cond/i){
			return 1;
		}
	}
	return 0;
}

sub count {
	my $self = shift;
	my $ref_line_splited = shift; 
	my @line_splited = @$ref_line_splited;
	
	if (!$self->_exclude_line(\@line_splited)){
		my $value = $line_splited[ $self->field_index ];
		if ($self->preprocess){
			$value = $self->_preprocess_field($value);
		}
		$self->_set_total_count($self->total_count + 1);
		$self->counters->{$value} += 1;
		foreach my $key (keys %{$self->other_counters}){
			if ($line_splited[$key] =~ m/$self->other_counters->{$key}/i){
				$self->other_counters_counts->{$value}->{$key}++;
			}
		}
		foreach my $summarizer_ref (@{$self->summarizers}){
			foreach my $key_summarize(keys %$summarizer_ref){
				$self->summarizers_sums->{$value}->{$key_summarize} += $line_splited[$summarizer_ref->{$key_summarize}];
			}
		}
	}
}

__PACKAGE__->meta->make_immutable;
1;

__END__
