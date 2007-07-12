package Lingua::YaTeA::RootNode;
use Lingua::YaTeA::Node;
use strict;

our @ISA = qw(Lingua::YaTeA::Node);

sub new
{
    my ($class,$level) = @_;
    my $this = $class->SUPER::new($level);
    bless ($this,$class);
    return $this;
}


1;

__END__

=head1 NAME

Lingua::YaTeA::RootNode - Perl extension for ???

=head1 SYNOPSIS

  use Lingua::YaTeA::RootNode;
  Lingua::YaTeA::RootNode->();

=head1 DESCRIPTION


=head1 METHODS

=head2 new()


=head1 SEE ALSO

Sophie Aubin and Thierry Hamon. Improving Term Extraction with
Terminological Resources. In Advances in Natural Language Processing
(5th International Conference on NLP, FinTAL 2006). pages
380-387. Tapio Salakoski, Filip Ginter, Sampo Pyysalo, Tapio Pahikkala
(Eds). August 2006. LNAI 4139.


=head1 AUTHOR

Thierry Hamon <thierry.hamon@lipn.univ-paris13.fr> and Sophie Aubin <sophie.aubin@lipn.univ-paris13.fr>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Thierry Hamon and Sophie Aubin

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
