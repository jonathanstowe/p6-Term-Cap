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

    use Grammar::Tracer;

    class X::NoTerminal is Exception {
        method message() { "no terminal type provided "; }
    }

    has Int $.ospeed;
    has Str $.term;
    has Num $.padding;

    has Str $.termcap;

    submethod BUILD(Int :$!ospeed = 9600, Str :$!term) {
        if  %*ENV<TERM>.defined  {
            $!term = %*ENV<TERM>;
        }
        elsif !$!term.defined  {
            X::NoTerminal.new.throw;
        }
        $!padding = calculate-padding($!ospeed);
    }

    multi sub calculate-padding(Int $ospeed where { $ospeed < 16 }) returns Num {
        my @pad = ( 0, 200, 133.3, 90.9, 74.3, 66.7, 50, 33.3,
               16.7, 8.3, 5.5, 4.1, 2, 1, .5, .2);
        return @pad[$ospeed];
    }

    multi sub calculate-padding(Int $ospeed) returns Num {
        return (10000 / $ospeed).Num;
    }

    method termcap() returns Str {
        $!termcap //= do {
            if %*ENV<TERMCAP> -> $tc {
                $tc;
            }
            else {
                self.termcap-files.first.slurp;
            }
        };
    }

    method termpath() {
        my @termpath;
        if %*ENV<TERMPATH> -> $tp {
            @termpath.append: $tp.split(':');
        }
        @termpath.append: </etc /usr/share/misc>;
    }

    method termcap-files() {
        my @files = ($*HOME.child('.termcap'), |self.termpath.map({ $_.IO.child('termcap') }), %?RESOURCES<etc/termcap> ).grep({ $_.f});
        @files;
    }




    grammar Parser {
        rule comment          { ^^\#.*?$$ }
        rule blank            { ^^\s*$$ }
        rule comment-or-blank { <comment>||<blank> }
        rule continuation     { \\\s*$$ }
        rule empty-cap        { \s*\\\s* }
        token cap             { \w\w }
        token num-val         { \d+ }
        token esc             { \\E }
        token od              { <[0 .. 7]> }
        token oct-val         { <od><od><od> }
        token oct-chr         { \\<oct-val> }
        token nl              { \\n }
        token ret             { \\r }
        token tab             { \\t }
        token ff              { \\f }
        token caret           { \\\^ }
        token ctrl-char       { <:Lu> }
        token ctrl            { \^<ctrl-char> }
        token del             { \^\? }
        token char            { . }
        token esc-char        { \\<char> }
        regex special         {
                                <value=esc>      ||
                                <value=oct-chr>  ||
                                <value=nl>       ||
                                <value=ret>      ||
                                <value=tab>      ||
                                <value=ff>       ||
                                <value=caret>    ||
                                <value=ctrl>     ||
                                <value=del>      ||
                                <value=esc-char>
                              }
        token literal         { . }
        token str-val         { [ <value=special> || <value=literal> ]+ }
        token true-bool       { <name=cap> }
        token false-bool      { <name=cap>\@ }
        token num-cap         { <name=cap>\#<value=num-val> }
        token str-cap         { <name=cap>\=<value=str-val> }
        token tc-cap          { tc\=<term=str-val> }
        token capability      { <capability=true-bool>||<capability=false-bool>||<capability=num-cap>||<capability=str-cap>||<tc-cap> }
        token name            { <-[\|\:]>+ }
        token names           { <name>+ % '|' }
        regex record          { ^^ <names> ':' [ <capability> | <continuation> | <empty-cap> ]+ %% ':' }
        token TOP             { [ <comment-or-blank> || <record> ] + }
    }

    class Actions  {
        method cap($/) {
            $/.make: ~$/;
        }
        method num-val($/) {
            $/.make: ~$/.Int +0;
        }
        method esc($/) {
            $/.make("\o[033]");
        }
        method oct-chr($/) {
            my $val = $/<oct-val>.Str;
            my $oct-val = :8($val).chr;
            $/.make($oct-val);
        }
        method nl($/) {
            $/.make("\n");
        }
        method ret($/) {
            $/.make("\r");
        }
        method tab($/) {
            $/.make("\t");
        }
        method ff($/) {
            $/.make("\f");
        }
        method caret($/) {
            $/.make('^');
        }
        method del($/) {
            $/.make("\o[177]");
        }
        method ctrl($/) {
            my $char = $/<ctrl-char>;
            my $ctrl-char = pack('C',ord($char) +& 31).decode ;
            $/.make($ctrl-char);
        }
        method esc-char($/) {
            $/.make($/<char>);
        }
        method literal($/) {
            $/.make(~$/);
        }
        method special($/) {
            my $val = $/<value>.made;
            $/.make($val);
        }
        method str-val($/) {
            my $val = $/<value>.list.map( { .made }).join('');
            $/.make($val);
        }
        method true-bool($/) {
            $/.make: $<name>.made => True;
        }
        method false-bool($/) {
            $/.make: $<name>.made => False;
        }
        method num-cap($/) {
            $/.make: $<name>.made => $<value>.made;
        }
        method str-cap($/) {
            $/.make: $<name>.made => $<value>.made;
        }
        method TOP($/) {
            $/.make: $<capability>.made;
        }

    }

    method description() {
        Parser.parse(self.termcap);
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
