package TAN::Model::MySQL;
use strict;

use TAN::DBProfiler;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'TAN::Schema',
    
    connect_info => {
        dsn => 'dbi:mysql:database=thisaintnews;host=localhost;mysql_socket=/var/run/mysqld/mysqld.sock',
        user => 'haha',
        password => 'caBi2ieL',
    }
);

sub BUILD{
    my $self = shift;
    $self->storage->debugobj( TAN::DBProfiler->new() );
    
    $self->storage->debug( $ENV{'CATALYST_DEBUG'});
    return $self;
}

sub reset_count {
    my $self = shift;
    my $debugobj = $self->storage()->debugobj();

    if($debugobj) {
        $debugobj->{_queries} = 0;
        $debugobj->{total_time} = 0;
    }

    return 1;
}

sub get_query_count {
    my $self = shift;
    my $debugobj = $self->storage()->debugobj();

    if($debugobj) {
        return $debugobj->{_queries};
    }

    return;
}

=head1 NAME

TAN::Model::MySQL - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<TAN>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<TAN::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.29

=head1 AUTHOR

root

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
