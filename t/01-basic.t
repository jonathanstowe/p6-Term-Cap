use v6;

use lib 'lib';

use Test;

use Term::Cap;

my $obj;

lives_ok { $obj = Term::Cap.new() }, "Create a new Term::Cap";

isa_ok($obj, Term::Cap, "and its the right type of object");


