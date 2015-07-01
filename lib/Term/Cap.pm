use v6;

=begin pod

=begin NAME

Term::Cap - provide access to terminal capability database

=end NAME

=begin SYNOPSIS

=begin code

    use Term::Cap;
    my $terminal = Term::Cap.new(term => 'vt220', ospeed => $ospeed);
    $terminal.require(<ce ku kd>);
    $terminal.goto('cm', $col, $row, $FH);
    $terminal.puts('dl', $count, $FH);
    $terminal.pad($string, $count, $FH);

=end code

=end SYNOPSIS

=begin DESCRIPTION

These are low-level functions to extract and use capabilities from
a terminal capability (termcap) database.

More information on the terminal capabilities will be found in the
termcap manpage on most Unix-like systems.

=end DESCRIPTION

=end pod

class Term::Cap {

    class X::NoTerminal is Exception {
        method message() { "no terminal type provided "; }
    }

    has Int $.ospeed;
    has Str $.term;
    has Num $.padding;

    submethod BUILD(Int :$!ospeed = 9600, Str :$!term) {
        if  %*ENV<TERM>.defined  {
            $!term = %*ENV<TERM>;
        }
        elsif !$!term.defined  {
            X::NoTerminal.new.throw;
        }
        $!padding = calculate_padding($!ospeed);
    }

    multi sub calculate_padding(Int $ospeed where { $ospeed < 16 }) returns Num {
        my @pad = ( 0, 200, 133.3, 90.9, 74.3, 66.7, 50, 33.3,
               16.7, 8.3, 5.5, 4.1, 2, 1, .5, .2);
        return @pad[$ospeed];
    }

    multi sub calculate_padding(Int $ospeed) returns Num {
        return (10000 / $ospeed).Num;
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
