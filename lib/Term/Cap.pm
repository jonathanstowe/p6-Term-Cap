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

    grammar Grammar {
        rule comment          { ^^\# }
        rule blank            { ^^\s*$$ }
        rule comment_or_blank { <comment>|<blank> }
        rule continuation     { \\\s*$$ }
        rule empty_cap        { \s*\\\s* }
        token cap             { \w\w }
        token num_val         { \d+ }
        token esc             { \\E }
        token od              { <[0 .. 7]> }
        token oct_val         { <od><od><od> }
        token oct_chr         { \\<oct_val> }
        token nl              { \\n }
        token ret             { \\r }
        token tab             { \\t }
        token ff              { \\f }
        token caret           { \\\^ }
        token ctrl_char       { <:Lu> }
        token ctrl            { \^<ctrl_char> }
        token del             { \^\? }
        token char            { . }
        token esc_char        { \\<char> }
        regex special         {  
                                <value=esc>      || 
                                <value=oct_chr>  ||
                                <value=nl>       ||
                                <value=ret>      ||
                                <value=tab>      ||
                                <value=ff>       ||
                                <value=caret>    ||
                                <value=ctrl>     ||
                                <value=del>      ||
                                <value=esc_char> 
                              }
        token literal         { . }
        token str_val         { [ <value=special> || <value=literal> ]+ }
        token true_bool       { <name=cap> }
        token false_bool      { <name=cap>\@ }
        token num_cap         { <name=cap>\#<value=num_val> }
        token str_cap         { <name=cap>\=<value=str_val> }
        token capability      { ^<capability=true_bool>|<capability=false_bool>|<capability=num_cap>|<capability=str_cap>$ }
        token name            { <-[\|\:]>+ }
        token names           { <name>+ % '|' }
        regex record          { ^^ <names> ':' [ <capability> | <continuation> | <empty_cap> ]+ %% ':' }
        token TOP             { [ <comment_or_blank> || <record> ] + }
    }

    class Actions  {
        method cap($/) {
            $/.make: ~$/;
        }
        method num_val($/) {
            $/.make: ~$/.Int +0;
        }
        method esc($/) {
            $/.make("\o[033]");
        }
        method oct_chr($/) {
            my $val = $/<oct_val>.Str;
            my $oct_val = :8($val).chr;
            $/.make($oct_val);
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
            my $char = $/<ctrl_char>;
            my $ctrl_char = pack('C',ord($char) +& 31).decode ;
            $/.make($ctrl_char);
        }
        method esc_char($/) {
            $/.make($/<char>);
        }
        method literal($/) {
            $/.make(~$/);
        }
        method special($/) {
            my $val = $/<value>.made;
            $/.make($val);
        }
        method str_val($/) {
            my $val = $/<value>.list.map( { .made }).join('');
            $/.make($val);
        }
        method true_bool($/) {
            $/.make: $<name>.made => True;
        }
        method false_bool($/) {
            $/.make: $<name>.made => False;
        }
        method num_cap($/) {
            $/.make: $<name>.made => $<value>.made;
        }
        method str_cap($/) {
            $/.make: $<name>.made => $<value>.made;
        }
        method TOP($/) {
            $/.make: $<capability>.made;
        }
    }

}
# vim: expandtab shiftwidth=4 ft=perl6
