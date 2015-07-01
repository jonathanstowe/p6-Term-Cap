use v6;

module Term::Cap::X {

    class NoTerminal is Exception {
        method message() { "no terminal type provided "; }
    }
}
