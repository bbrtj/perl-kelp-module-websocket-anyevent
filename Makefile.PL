use 5.010000;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => 'Kelp::Module::WebSocket::AnyEvent',
	VERSION_FROM => 'lib/Kelp/Module/WebSocket/AnyEvent.pm',
	MIN_PERL_VERSION => '5.010',
	PREREQ_PM => {
		'Kelp' => '>= 1',
		'Plack::App::WebSocket' => '>= 0.08',
		'Try::Tiny' => 0,
	},
	ABSTRACT_FROM => 'lib/Kelp/Module/WebSocket/AnyEvent.pm',
	AUTHOR => 'Bartosz Jarzyna <brtastic.dev@gmail.com>',
	LICENSE => 'perl',
);
