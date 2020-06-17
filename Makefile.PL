use ExtUtils::MakeMaker;

my $meta_merge = {
    META_MERGE => {
        resources => {
            repository => 'https://github.com/tomhughes/IO-Zlib.git',
            bugtracker => 'https://github.com/tomhughes/IO-Zlib/issues',
        },
    }
};

WriteMakefile(
	NAME         => 'IO::Zlib',
	VERSION_FROM => 'Zlib.pm',
        PREREQ_PM    => { 'Compress::Zlib' => 2.000 },
        SIGN         => 1,
        INSTALLDIRS  => $] >= 5.00903 ? 'perl' : 'site',
	dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' },
	$ExtUtils::MakeMaker::VERSION >= 6.50 ? (%$meta_merge) : (),
);
