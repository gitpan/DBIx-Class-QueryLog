#!perl -T

use strict;
use warnings;
use Test::More tests => 10;

use DBIx::Class::QueryLog;
use DBIx::Class::QueryLog::Query;
use DBIx::Class::QueryLog::Transaction;

my $ql = new DBIx::Class::QueryLog();
ok($ql->isa('DBIx::Class::QueryLog'), 'new');

$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
ok(scalar(@{ $ql->log() }) == 1, 'log count w/1 query');

$ql->txn_begin();
$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
$ql->txn_commit();

ok(scalar(@{ $ql->log() }) == 2, 'log count w/1 query + 1 trans');
my $log = $ql->log();
ok(scalar(@{ $log->[1]->queries() }) == 1, '1 query in txn');
ok($log->[1]->committed, 'Committed txn');
ok(!$log->[1]->rolledback, '! Rolled back txn');

$ql->txn_begin();
$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
$ql->txn_rollback();

ok(scalar(@{ $ql->log() }) == 3, 'log count w/1 query + 2 trans');
$log = $ql->log();
ok(scalar(@{ $log->[2]->queries() }) == 2, '2 queries in 2nd txn');
ok($log->[2]->rolledback, 'Rolled back 2nd txn');
ok(!$log->[2]->committed, 'Not committed 2nd txn');