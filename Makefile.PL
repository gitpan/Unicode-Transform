use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

require 5.006;

WriteMakefile(
    'NAME'		=> 'Unicode::Transform',
    'VERSION_FROM'	=> 'Transform.pm',
    'ABSTRACT_FROM'	=> 'Transform.pm',
    'AUTHOR'		=> 'SADAHIRO Tomoyuki <SADAHIRO@cpan.org>',
);
