package DBIx::Class::QueryLog::Query;

use warnings;
use strict;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(bucket start_time end_time sql params));

=head1 NAME

DBIx::Class::QueryLog::Query - A Query

=head1 SYNOPSIS

Represents a query.  The sql, parameters, start time and end time are stored.

=head1 METHODS

=head2 bucket

The bucket this query is in.

=head2 start_time

Time this query started.

=head2 end_time

Time this query ended.

=head2 sql

SQL for this query.

=head2 params

Parameters used with this query.

=head2 time_elapsed

Time this query took to execute.  start - end.

=cut

sub time_elapsed {
	my $self = shift;

	return $self->end_time - $self->start_time;
}

=head2 count

Returns 1.  Exists to make it easier for QueryLog to get a count of
queries executed.

=cut
sub count {

    return 1;
}

=head2 queries

Returns this query, here to make QueryLog's job easier.

=cut
sub queries {
    my $self = shift;

    return [ $self ];
}

=head2 get_sorted_queries

Returns this query.  Here to make QueryLog's job easier.

=cut
sub get_sorted_queries {
    my $self = shift;

    return [ $self ];
}

=head1 AUTHOR

Cory 'G' Watson, C<< <gphat at cpan.org> >>

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Cory 'G' Watson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;