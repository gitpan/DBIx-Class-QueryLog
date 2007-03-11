use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'DBIx::Class::QueryLog',
    AUTHOR              => "Cory 'G' Watson <gphat\@cpan.org>",
    VERSION_FROM        => 'lib/DBIx/Class/QueryLog.pm',
    ABSTRACT_FROM       => 'lib/DBIx/Class/QueryLog.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'		=> 0,
		'Class::Accessor'	=> 0,
		'Time::HiRes'		=> 0,
		'DBIx::Class'		=> 0,
		'Sort::Key'			=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'DBIx-Class-QueryLog-*' },
);
