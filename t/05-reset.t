#!perl

use strict;
use warnings;
use Test::More tests => 4;

use DBIx::Class::QueryLog;
use DBIx::Class::QueryLog::Query;
use DBIx::Class::QueryLog::Transaction;


my $ql = DBIx::Class::QueryLog->new;
ok($ql->isa('DBIx::Class::QueryLog'), 'new');
ok($ql->isa('DBIx::Class::Storage::Statistics'), "extends base debug object");

$ql->query_start('SELECT * from foo');
$ql->query_end('SELECT * from foo');
ok(scalar(@{ $ql->log }) == 1, 'log count w/1 query');

$ql->reset;

eval {
    $ql->txn_begin;
    $ql->query_start('SELECT * from foo');
    $ql->query_end('SELECT * from foo');
    $ql->txn_commit;
};
ok(!$@, 'post reset queries');