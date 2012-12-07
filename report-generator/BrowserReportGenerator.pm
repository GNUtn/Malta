package BrowserReportGenerator;
use Mouse;
use HTML::ParseBrowser;
extends 'ReportGenerator';
require 'Utils.pm';


# El nombre del campo sobre el que se realiza la cuenta.
has 'field' =>(
	is      => 'rw',
	isa     => 'Str'
);

# Nombre de campo sobre el que se quiere filtrar.
has 'filter_field' =>(
	is      => 'rw',
	isa     => 'Str'
);

# Condición regex a aplicar para filtrar.
has 'filter_condition' =>(
	is      => 'rw',
	isa     => 'Str'
);

# el archivo a generar.
has 'file_name' =>(
	is      => 'rw',
	isa     => 'Str',
	reader	=> 'get_file_name'
);

sub parse_values {
	my ( $self, $values ) = @_;
	
	#TODO: agregar filtro (usar filter_field y filter_condition)
	my $category = @$values[ $self->config->{fields}->{$self->field} ];
	my $ua = HTML::ParseBrowser->new($category);
	my $data = "";
	if ($ua->name){
		$data =  $data . $ua->name;
		if ($ua->v){
			$data = $data . " " . $ua->v;
		} 
		my $date     = @$values[ $self->config->{fields}->{'date'} ];
		my $entry    = $self->get_entry( $date, $data );
		$entry->{ocurrencias} += 1;
	} 
}

sub get_entry {
	my ( $self, $date, $categoria ) = @_;

	if ( !exists $self->data_hash->{$date}->{$categoria} ) {
		$self->data_hash->{$date}->{$categoria} = $self->new_entry;
	}
	return $self->data_hash->{$date}->{$categoria};
}

sub new_entry {
	my ($self) = @_;
	my %entry = ( ocurrencias => 0, );
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 1;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria)];
}

sub get_sort_field {
	my ($self) = @_;
	return 'ocurrencias';
}
1;