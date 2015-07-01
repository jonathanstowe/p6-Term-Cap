use v6;

use lib 'lib';

use Test;

use Term::Cap;

my $obj;

lives-ok { $obj = Term::Cap.new() }, "Create a new Term::Cap";

isa-ok($obj, Term::Cap, "and its the right type of object");

%*ENV<TERM> = 'vt220' unless %*ENV<TERM>.defined;

is($obj.ospeed, 9600, "got correct default ospeed");
is($obj.term, %*ENV<TERM>, "got a default term from the environmen");

my $old_term = %*ENV<TERM>;

%*ENV<TERM>:delete;

throws-like { Term::Cap.new() }, Term::Cap::X::NoTerminal, "Creatng a new Term::Cap with no TERM in environment";

done;
