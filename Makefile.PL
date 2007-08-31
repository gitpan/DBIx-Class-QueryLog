use inc::Module::Install;

name    'DBIx-Class-QueryLog';
all_from    'lib/DBIx/Class/QueryLog.pm';

requires    'Test::More'		=> 0;
requires    'Class::Accessor'	=> 0;
requires    'Time::HiRes'		=> 0;
requires	'DBIx::Class'		=> 0;

auto_install;

WriteAll;