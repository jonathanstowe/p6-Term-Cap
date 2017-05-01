use v6;

use Test;

use Term::Cap;

my $obj;

%*ENV<TERM> = 'vt220' unless %*ENV<TERM>.defined;

lives-ok { $obj = Term::Cap.new() }, "Create a new Term::Cap";

isa-ok($obj, Term::Cap, "and its the right type of object");


is($obj.ospeed, 9600, "got correct default ospeed");
is($obj.term, %*ENV<TERM>, "got a default term from the environmen");

#ok $obj.termcap, "got the termcap";


{
    temp %*ENV;
    %*ENV<TERM>:delete;

    throws-like { Term::Cap.new() }, X::NoTerminal, "Creatng a new Term::Cap with no TERM in environment";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
