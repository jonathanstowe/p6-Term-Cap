use v6;

module Term::Cap::X {

    class NoTerminal is Exception {
        method message() { "no terminal type provided "; }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
