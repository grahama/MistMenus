use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'          => 'Mist::Menus',
    'VERSION_FROM'  => 'lib/Mist/Menus.pm', # finds $VERSION
#    'PREREQ_PM'     => { Text::Diff => 0 }, # e.g., Module::Name => 1.1
    'test'          => { TESTS => 't/*.t' },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Mist/Menus.pm', # retrieve abstract from module
       AUTHOR        => 'Albert Graham <albert.graham @gmail.com') : ()),
);
