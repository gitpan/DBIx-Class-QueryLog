package DBIx::Class::QueryLog::Analyzer;

use warnings;
use strict;

use base qw(Class::Accessor);
__PACKAGE__->mk_accessors(qw(querylog));

=head1 NAME

DBIx::Class::QueryLog::Analyzer - Query Analysis

=head1 SYNOPSIS

Analyzes the results of a QueryLog.  Create an Analyzer and pass it the
QueryLog:

    my $schema = ... # Get your schema!
    my $ql = new DBIx::Class::QueryLog();
    $schema->storage->debugobj($ql);
    $schema->storage->debug(1);
    ... # do some stuff!
    my $ana = DBIx::Class::QueryLog::Analyzer({ querylog => $ql });
    my @queries = $ana->get_sorted_queries();
    # or...
    my $totaled = $ana->get_totaled_queries();


=head1 METHODS

=head2 new

Create a new DBIx::Class::QueryLog::Analyzer

=cut

sub new {
    my $proto = shift();
    my $self = $proto->SUPER::new(@_);

    return $self;
}

=head2 get_sorted_queries

Returns a list of all Query objects, sorted by elapsed time (descending).

=cut

sub get_sorted_queries {
    my $self = shift();

    my @queries;

    foreach my $l (@{ $self->querylog->log() }) {
        push(@queries, @{ $l->get_sorted_queries() });
    }
    return [ reverse sort { $a->time_elapsed() <=> $b->time_elapsed() } @queries ];
}

=head2 get_totaled_queries

Returns hashref of the queries executed, with same-SQL combined and totaled.
So if the same query is executed multiple times, it will be combined into
a single entry.  The structure is:

    $var = {
        'SQL that was EXECUTED' => {
            count           => 2,
            time_elapsed    => 1931,
            queries         => [
                DBIx::Class::QueryLog...,
                DBIx::Class::QueryLog...
            ]
        }
    }

This is useful for when you've fine-tuned individually slow queries and need
to isolate which queries are executed a lot, so that you can determine which
to focus on next.

To sort it you'll want to use something like this (sorry for the long line, 
blame perl...):

    my $analyzed = $ana->get_totaled_queries();
    my @keys = reverse sort {
            $analyzed->{$a}->{'time_elapsed'} <=> $analyzed->{$b}->{'time_elapsed'}
        } keys(%{ $analyzed });

So one could sort by count or time_elapsed.

=cut

sub get_totaled_queries {
    my $self = shift();

    my %totaled;
    foreach my $l (@{ $self->querylog->log() }) {
        foreach my $q (@{ $l->queries() }) {
            $totaled{$q->sql()}->{'count'}++;
            $totaled{$q->sql()}->{'time_elapsed'} += $q->time_elapsed();
            push(@{ $totaled{$q->sql()}->{'queries'} }, $q);
        }
    }
    return \%totaled;
}

=head1 AUTHOR

Cory 'G' Watson C<< <gphat at cpan.org> >>

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Cory 'G' Watson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
1;
