# Term::Cap
Interface to the terminal capability database for Perl 6.

## Description

This is a re-implementation of the Perl 5 module Term::Cap for Perl 6.

It provides access to the terminal capabilities database for Unix like systems,
providing a usable set of defaults for platforms where there is no termcap or
terminfo available.


## Installation

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo 
    make test 
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Other install mechanisms may be become available in the future.


## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/p6-Term-Cap

I'm not able to test on a wide variety of platforms so any help there
would be appreciated.

## Licence

Please see the LICENCE file in the distribution directory

(C) Jonathan Stowe 2015
