class Term::Cap;

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

