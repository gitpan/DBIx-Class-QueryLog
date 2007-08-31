package DBIx::Class::QueryLog;

use warnings;
use strict;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(log current_transaction current_query));

use Time::HiRes;

use DBIx::Class::QueryLog::Query;
use DBIx::Class::QueryLog::Transaction;

=head1 NAME

DBIx::Class::QueryLog - Log queries for later analysis.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';

=head1 SYNOPSIS

DBIx::Class::QueryLog 'logs' each transaction and query executed so you can
analyze what happened in the 'session'.  It must be installed as the debugobj
in DBIx::Class:

    use DBIx::Class::QueryLog;

	my $schema = ... # Get your schema!
    my $ql = new DBIx::Class::QueryLog();
	$schema->storage->debugobj($ql);
	$schema->storage->debug(1);
    ... # do some stuff!

Every transaction and query executed will have a corresponding Transaction
and Query object stored in order of execution, like so:

	Query
	Query
	Transaction
	Query
	
This array can be retrieved with the log() method.  Queries executed inside
a transaction are stored inside their Transaction object, not inside the
QueryLog directly.

See L<DBIx::Class::QueryLog::Analyzer> for options on digesting the results
of a QueryLog session.

=head1 METHODS

=head2 new

Create a new DBIx::Class::QueryLog.

=cut
sub new {
    my $proto = shift();
    my $self = $proto->SUPER::new(@_);

	$self->log([]);

	return $self;
}

=head2 time_elapsed

Returns the total time elapsed for ALL transactions and queries in this log.

=cut
sub time_elapsed {
	my $self = shift();

	my $total = 0;
	foreach my $t (@{ $self->log() }) {
		$total += $t->time_elapsed();
	}

	return $total;
}

=head2 count

Returns the number of queries executed in this QueryLog

=cut
sub count {
    my $self = shift();

    my $total = 0;
	foreach my $t (@{ $self->log() }) {
		$total += $t->count();
	}

	return $total;
}

=head2 reset

Reset this QueryLog by removing all transcations and queries.

=cut
sub reset {
	my $self = shift();

	$self->log(undef);
}

=head2 add_to_log

Add this provided Transaction or Query to the log.

=cut
sub add_to_log {
	my $self = shift();
	my $thing = shift();

	push(@{ $self->log() }, $thing);
}

=head2 txn_begin

Called by DBIx::Class when a transaction is begun.

=cut

sub txn_begin {
	my $self = shift();

	$self->current_transaction(
		new DBIx::Class::QueryLog::Transaction({
			start_time => Time::HiRes::time()
		})
	);
}

=head2 txn_commit

Called by DBIx::Class when a transaction is committed.

=cut

sub txn_commit {
	my $self = shift();

	if(defined($self->current_transaction())) {
		my $txn = $self->current_transaction();
		$txn->end_time(Time::HiRes::time());
		$txn->committed(1);
		$txn->rolledback(0);
		push(@{ $self->log() }, $txn);
		$self->current_transaction(undef);
	} else {
		warn('Unknown transaction committed.')
	}
}

=head2 txn_rollback

Called by DBIx::Class when a transaction is rolled back.

=cut

sub txn_rollback {
	my $self = shift();

	if(defined($self->current_transaction())) {
		my $txn = $self->current_transaction();
		$txn->end_time(Time::HiRes::time());
		$txn->committed(0);
		$txn->rolledback(1);
		$self->add_to_log($txn);
		$self->current_transaction(undef);
	} else {
		warn('Unknown transaction committed.')
	}
}

=head2 query_start

Called by DBIx::Class when a query is begun.

=cut

sub query_start {
	my $self = shift();
	my $sql = shift();
	my @params = @_;

	$self->current_query(
		new DBIx::Class::QueryLog::Query({
			start_time 	=> Time::HiRes::time(),
			sql			=> $sql,
			params		=> \@params,
		})
	);
}

=head2 query_end

Called by DBIx::Class when a query is completed.

=cut

sub query_end {
	my $self = shift();

	if(defined($self->current_query())) {
		my $q = $self->current_query();
		$q->end_time(Time::HiRes::time());
		if(defined($self->current_transaction())) {
			$self->current_transaction->add_to_queries($q);
		} else {
			$self->add_to_log($q)
		}
		$self->current_query(undef);
	} else {
		warn('Completed unknown query.');
	}
}

=head1 AUTHOR

Cory 'G' Watson, C<< <gphat at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-dbix-class-querylog at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-Class-QueryLog>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::Class::QueryLog

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-Class-QueryLog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-Class-QueryLog>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-Class-QueryLog>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-Class-QueryLog>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Cory 'G' Watson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of DBIx::Class::QueryLog
