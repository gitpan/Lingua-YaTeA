#!/usr/bin/perl

package Lingua::YaTeA::XMLEntities;
use strict;


sub encode
{
    $_[0]=~s/&/&amp;/g;
    $_[0]=~s/\"/&quot;/g;
    $_[0]=~s/\'/&apos;/g;
    $_[0]=~s/</&lt;/g;
    $_[0]=~s/>/&gt;/g;
}


=head2 decode($line)

This method decodes XML entities corresponding to special XML characters in the line C<$line> .

=cut


sub decode
{
    $_[0]=~s/&quot;/\"/g;
    $_[0]=~s/&apos;/\'/g;
    $_[0]=~s/&amp;/&/g;
    $_[0]=~s/&lt;/</g;
    $_[0]=~s/&gt;/>/g;
}

1;

__END__

=head1 NAME

Lingua::YaTeA::XMLEntities - Perl extension for managing characters which can not be used in a  XML
document

=head1 SYNOPSIS


use Lingua::YaTeA::XMLEntities;

Lingua::YaTeA::XMLEntities::decode($line);


Lingua::YaTeA::XMLEntities::eecode($line);

=head1 DESCRIPTION

This module is used to encode or decode special XML characters
(C<&>, C<'>, C<">, E<gt>, E<lt>).

=head1 METHODS

=head2 encode($line)

This method encodes special XML characters as XML entities in the line C<$line>.


=cut


=head1 SEE ALSO

C<Alvis::NLPPlatform>

Alvis web site: http://www.alvis.info

=head1 AUTHORS

Guillaume Vauvert <guillaume.vauvert@lipn.univ-paris13.fr>

Currently maintained by Julien Deriviere <julien.deriviere@lipn.univ-paris13.fr> and Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr>

=head1 LICENSE

Copyright (C) 2004 by Guillaume Vauvert, Thierry Hamon and Julien Deriviere

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

