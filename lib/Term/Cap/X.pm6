module Term::Cap::X;

class Term::Cap::X::NoTerminal is Exception {
   sub message() { "no terminal type provided "; }
}
