package DBIx::Class::QueryLog::Transaction;

use warnings;
use strict;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(start_time end_time queries committed rolledback));

=head1 NAME

DBIx::Class::QueryLog::Transaction - A Transaction

=head1 SYNOPSIS

Represents a transaction.  All queries executed with the context of this
transaction are stored herein, as well as a start time, end time and flag
for committed or rolledback.

=head1 METHODS

=head2 new

Create a new DBIx::Class::QueryLog::Transcation

=cut

sub new {
    my $proto = shift();
    my $self = $proto->SUPER::new(@_);

	$self->queries([]);

	return $self;
}

=head2 queries

Arrayref containing all queries executed, in order of execution.

=head2 committed

Flag indicating if this transaction was committed.

=head2 rolledback

Flag indicating if this transaction was rolled back.

=head2 start_time

Time this transaction started.

=head2 end_time

Time this transaction ended.

=head2 time_elapsed

Time this transaction took to execute.  start - end.

=cut
sub time_elapsed {
	my $self = shift();

	my $total = 0;
	foreach my $q (@{ $self->queries() }) {
		$total += $q->time_elapsed();
	}

	return $total;
}

=head2 add_to_queries

Add the provided query to this transactions list.

=cut
sub add_to_queries {
	my $self = shift();
	my $query = shift();

	push(@{ $self->queries() }, $query);
}

=head2 count

Returns the number of queries in this Transaction

=cut
sub count {
    my $self = shift();

    return scalar(@{ $self->queries() });
}

=head2 get_sorted_queries

Returns all the queries in this Transaction, sorted by elapsed time. (descending)

=cut
sub get_sorted_queries {
    my $self = shift();

    return [ reverse sort { $a->time_elapsed() <=> $b->time_elapsed() } @{ $self->queries() } ];
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