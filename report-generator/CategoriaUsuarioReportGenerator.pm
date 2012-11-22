package CategoriaUsuarioReportGenerator;
use Mouse;
extends 'ReportGenerator';
require 'Utils.pm';

sub parse_values {
	my ( $self, $values ) = @_;
	my $action = @$values[ $self->config->{fields}->{'action'} ];
	
	if ($action eq 'Denied') {
		my $date = @$values[ $self->config->{fields}->{'date'} ];
		my $category = @$values[ $self->config->{fields}->{'UrlCategory'} ];
		my $user = @$values[ $self->config->{fields}->{'cs-username'} ];
		my $entry = $self->get_entry( $date, $category, $user );
		$entry->{ocurrencias} += 1;
	}
}

sub get_file_name {
	return "categoria_usuario.json";
}

sub get_entry {
	my ( $self, $date, $categoria, $usuario ) = @_;

	if ( !exists $self->data_hash->{$date}->{$categoria}->{$usuario} ) {
		$self->data_hash->{$date}->{$categoria}->{$usuario} = $self->new_entry;
	}

	return $self->data_hash->{$date}->{$categoria}->{$usuario};
}

sub get_global_results {
       my ($self) = @_;
       foreach my $date ( keys %{ $self->data_hash } ) {
               foreach my $categoria ( keys %{ $self->data_hash->{$date} } ) {
                       foreach my $usuario (keys %{$self->data_hash->{$date}->{$categoria}}){
                               if ( exists $self->data_hash->{$categoria}->{$usuario} ) {
                                       $self->data_hash->{$categoria}->{$usuario}->{ocurrencias} +=
                                         $self->data_hash->{$date}->{$categoria}->{$usuario}->{ocurrencias};
                               } else {
                                       $self->data_hash->{$categoria}->{$usuario} = $self->data_hash->{$date}->{$categoria}->{$usuario};
                               }
                       }
               }
               delete($self->data_hash->{$date});
       }
       return $self->data_hash;
}

sub new_entry {
	my ($self) = @_;
	my %entry = (
		ocurrencias => 0
	);
	return \%entry;
}

sub get_level {
	my ($self) = @_;
	return 2;
}

sub get_fields {
	my ($self) = @_;
	return [qw(categoria usuario)];
}

sub get_sort_field {
	my ( $self ) = @_;
	return 'ocurrencias';
}
1;
